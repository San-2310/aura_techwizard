import os
import pandas as pd
import tensorflow as tf
import numpy as np
from tensorflow.keras.layers import TextVectorization
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dropout, Bidirectional, Dense, Embedding
from tensorflow.keras.metrics import Precision, Recall, CategoricalAccuracy
from matplotlib import pyplot as plt

print(os.getcwd()) 

df = pd.read_csv(os.path.join('train.csv'))

print(df.head())
print(df.tail())
print(df.iloc[3]['comment_text'])
print(df[df.columns[2:]].iloc[3])

X = df['comment_text']
y = df[df.columns[2:]].values  # Converts data to array using .values


MAX_FEATURES = 200000

vectorizer = TextVectorization(max_tokens=MAX_FEATURES,
                               output_sequence_length=2000,  # Comment max length
                               output_mode='int')


vectorizer.adapt(X.values) 

print(vectorizer('Hello world'))

vectorized_text = vectorizer(X.values)

dataset = tf.data.Dataset.from_tensor_slices((vectorized_text, y))
dataset = dataset.cache()
dataset = dataset.shuffle(160000)
dataset = dataset.batch(16)
dataset = dataset.prefetch(8)  

train = dataset.take(int(len(dataset) * 0.7))
val = dataset.skip(int(len(dataset) * 0.7)).take(int(len(dataset) * 0.2))
test = dataset.skip(int(len(dataset) * 0.9)).take(int(len(dataset) * 0.1))

model = Sequential()

model.add(Embedding(MAX_FEATURES + 1, 32))

model.add(Bidirectional(LSTM(32, activation='tanh')))

model.add(Dense(128, activation='relu'))
model.add(Dense(256, activation='relu'))
model.add(Dense(128, activation='relu'))

model.add(Dense(6, activation='sigmoid'))

model.compile(loss='BinaryCrossentropy', optimizer='Adam')

model.summary()

history = model.fit(train, epochs=3, validation_data=val)

plt.plot(history.history['loss'], label='train_loss')
plt.plot(history.history['val_loss'], label='val_loss')
plt.legend()
plt.show()

input_text = vectorizer("You freaking suck!")
batch = test.as_numpy_iterator().next()
batch_X, batch_y = test.as_numpy_iterator().next()

print((model.predict(batch_X) > 0.5).astype(int))

res = model.predict(batch)

pre = Precision()
re = Recall()
acc = CategoricalAccuracy()

for batch_X, batch_y in test.as_numpy_iterator():
    y_pred = model.predict(batch_X)
    y_pred = (y_pred > 0.5).astype(int)  

    pre.update_state(batch_y, y_pred)
    re.update_state(batch_y, y_pred)
    acc.update_state(batch_y, y_pred)

print(f"Precision: {pre.result().numpy()}")
print(f"Recall: {re.result().numpy()}")
print(f"Categorical Accuracy: {acc.result().numpy()}")
