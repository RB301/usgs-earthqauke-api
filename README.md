# Real-Time Earthquake Data Service

The solution comprises a Python API server, crafted with FastAPI, containerised using Docker, and designed for deployment onto a Kubernetes cluster managed by AWS EKS, orchestrated with Terraform and Helm.

The API server provides the following endpoints:

- `GET /users`: Retrieves a list of all users (demonstrates data persistence).
- `POST /user`: Creates a new user (demonstrates data persistence and basic error handling).
- `GET /earthquakes`: Retrieves earthquake data from the USGS API (your original endpoint).
- `GET /earthquakes/felt_reports`: Retrieves earthquake data with felt reports (your original endpoint).

## Prerequisites

Before you get cracking, you'll need the following bits and bobs installed and set up:

- Ubuntu Linux environment
- Docker installed
- Terraform installed
- Helm installed
- kubectl installed and configured to connect to an EKS cluster (if you're deploying)
- AWS CLI configured with the proper credentials (if you're using Terraform)


## Getting Started - Running the Application

Here's a step-by-step guide to get the application up and running:


3.  **Run the Python API Server Locally (Optional):** If you fancy a quick peek at the API without Docker, you can run it locally:
    ```bash
    uvicorn main:app --reload
    ```
    You can then have a gander at the API endpoints (e.g., `http://127.0.0.1:8000/users`, `http://127.0.0.1:8000/user`, `http://127.0.0.1:8000/earthquakes`) in your web browser or using a tool like `curl`.

4.  **Build the Docker Image:** To containerise the application, head back to the root of the repository and build the Docker image:
    ```bash
    docker build -t your-dockerhub-username/prima-app:latest .
    ```

5.  **Push the Docker Image to Docker Hub:** Once the image is built, push it to your Docker Hub repository:
    ```bash
    docker push your-dockerhub-username/prima-app:latest
    ```

6.  **Infrastructure as Code with Terraform:** If you're looking to deploy this on AWS EKS, the `terraform/` directory contains the configuration for that.

    ```bash
    cd terraform
    terraform init
    terraform apply
    ```

7.  **Deploying to Kubernetes with Helm:** Once you have a Kubernetes cluster up and running (either provisioned with Terraform or an existing one), you can use the Helm chart in the `helm/prima-app/` directory to deploy the application.

    ```bash
    cd ../helm/prima-app
    helm install prima-app . -n default
    ```

    This will deploy the application to the `default` namespace. You can check the status of the deployment using `kubectl get deployments -n default` and `kubectl get services -n default`. The application should be accessible via a LoadBalancer IP address or through an Ingress controller if you've got one set up.

## Python API Server Details

The Python API server, built using the rather nippy FastAPI framework, offers the following ways to interact with it:

- `GET /users`: Gives you a list of all the users we've got (shows how we're keeping tabs on things with SQLite).
- `POST /user`: Lets you add a new user to the system (again, using our SQLite database, and it'll even grumble if you try to add someone who's already here).
- `GET /earthquakes?start_time=YYYY-MM-DD&end_time=YYYY-MM-DD`: Fetches earthquake data from the USGS API for a specific period. Just pop in your start and end dates in the `YYYY-MM-DD` format.
- `GET /earthquakes/felt_reports?start_time=YYYY-MM-DD&end_time=YYYY-MM-DD&min_magnitude=FLOAT`: Gets you earthquake data with ten or more felt reports from the USGS API, within a given timeframe and above a certain magnitude.

User information is stashed away in an SQLite database (`users.db`) located in the `app/` directory. We've also put in some basic checks to handle things like trying to create a user with a name that's already taken.

## Docker Image

The application is packaged up nice and neat in a Docker image. The `Dockerfile` starts with a lean Python 3.9 image, installs all the necessary bits from the `requirements.txt` file, and sets up the command to run the FastAPI application using Uvicorn.

## Infrastructure as Code (Terraform)

The `terraform/` directory holds the Terraform configuration, which is used to orchestrate the creation of an Amazon EKS (Elastic Kubernetes Service) cluster and the bits and bobs it needs in the `eu-west-2` AWS region. Have a look at the files in there (`main.tf`, `variables.tf`, `outputs.tf`) for the specifics of what's being set up.

## Kubernetes Deployment with Helm

Inside the `helm/prima-app/` directory, you'll find a basic Helm chart. This makes deploying our Dockerised Python API server onto a Kubernetes cluster a breeze. The chart includes blueprints for a Deployment (how our application will run) and a Service (how it will be accessed). You can tweak the deployment settings (like how many copies of the app to run, the Docker image tag, and how the service is exposed) by fiddling with the `values.yaml` file.

contains a full-fledged solution for the Prima Senior SRE Technical Challenge, covering the development of a Python API server, getting it into a Docker container, setting up the infrastructure on AWS EKS using Terraform, deploying it with Helm on Kubernetes. While getting the infrastructure fully automated might require a bit of tinkering with AWS credentials, the configurations provided should give you a good idea of the intended approach and the technologies involved.

## Tech Stack

- **Programming Language**: Python
- **Web Framework**: FastAPI
- **Containerization**: Docker
- **Data Source**: USGS Earthquake API
- **Output Formats**: JSON, XML 
- **Architecture**: Stateless, highly available, and scalable setup using Docker containers.




## Requirements

- **Python 3.x**: The service is written in Python and requires Python 3.x.
- **FastAPI**: For building the RESTful API.
- **Uvicorn**: ASGI server for serving the FastAPI app.
- **Docker**: The service is containerized using Docker. Ensure that Docker is installed and running on your system.


## Architecture
https://miro.com/app/board/uXjVKnrXYmc=/
