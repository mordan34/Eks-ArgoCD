FROM python:3.6

# Creating Application Source Code Directory
RUN mkdir -p /k8s_python/src

# Setting Home Directory for containers
WORKDIR /k8s_python/src

# Installing python dependencies
COPY requirements.txt /k8s_python/src
RUN pip install --no-cache-dir -r requirements.txt

# Copying src code to Container
COPY . /k8s_python/src

# Application Environment variables
ENV APP_ENV development

# Exposing Ports
EXPOSE 5035

# configure the container to run in an executed manner
ENTRYPOINT [ "python" ]

# Running Python Application
CMD ["presentcontent.py" ]