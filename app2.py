from flask import Flask
app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def hello_world():
  print('Received a request')
  return 'Hello, World! from SJSU-2\n'

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=8080)