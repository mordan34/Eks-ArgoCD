#!/usr/bin/env python3
from flask import Flask, render_template, request
import os
import boto3
from botocore.exceptions import ClientError


# To check whether root bucket exists or not
def bucket_exists(bucket_name):
   try:
      session = boto3.session.Session()
      # User can pass customized access key, secret_key and token as well
      s3_resource = session.resource('s3')
      s3_resource.meta.client.head_bucket(Bucket=bucket_name)
      print("Bucket exists.", bucket_name)
      exists = True
      print(request.script_root)
   except ClientError as error:
      error_code = int(error.response['Error']['Code'])
      if error_code == 403:
         print("Private Bucket. Forbidden Access! ", bucket_name)
      elif error_code == 404:
         print("Bucket Does Not Exist!", bucket_name)
      exists = False
      return exists

def extract_path():
   path=request.path
   parts=path.strip('/').split('/')
   if len(parts)==2:
        return parts[0],parts[1]
   else: return False

def getS3file(bucket_name, filename):
    session = boto3.session.Session()
      # User can pass customized access key, secret_key and token as well
    s3 = session.resource('s3')
    obj = s3.Object(bucket_name, filename)
    data=obj.get()['Body'].read()
    print(data)

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('index.html')


@app.route("/my-pages-bucket/page.html")
def getitem():
    bucket_name,filename=extract_path()
    print("Bucket name is: ", bucket_name)
    print("Required filename is: ", filename)
    if bucket_exists(bucket_name):
       getS3file(bucket_name, filename)
    else: return render_template('index.html')


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5035))
    app.run(debug=True, host='0.0.0.0', port=port)