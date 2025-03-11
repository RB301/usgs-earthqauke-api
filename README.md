# Real-Time Earthquake Data Service

This project provides a scalable and highly available service to offer real-time earthquake data from the United States Geological Survey (USGS). The service extends the USGS’ earthquake API and provides a RESTful HTTP API with custom endpoints to serve specific earthquake data queries for the San Francisco Bay Area and other U.S. states.

## Tech Stack

- **Programming Language**: Python
- **Web Framework**: FastAPI
- **Containerization**: Docker
- **Data Source**: USGS Earthquake API
- **Output Formats**: JSON, XML 
- **Architecture**: Stateless, highly available, and scalable setup using Docker containers.

## Features

This service includes the following custom endpoints:

## Requirements

- **Python 3.x**: The service is written in Python and requires Python 3.x.
- **FastAPI**: For building the RESTful API.
- **Uvicorn**: ASGI server for serving the FastAPI app.
- **Docker**: The service is containerized using Docker. Ensure that Docker is installed and running on your system.


## Architecture
https://miro.com/app/board/uXjVKnrXYmc=/
This system uses a stateless API design and is built to run in a highly available setup. Multiple Docker containers will be deployed to handle different parts of the service, ensuring scalability and high availability.

### Docker Setup

1. **Docker Compose** will be used to manage multiple containers.
2. Containers will be configured to scale horizontally to handle high loads.
3. The service will ensure that the USGS API is not overloaded by implementing a rate-limiting mechanism (30-second interval between repeated requests).

## Installation & Usage

1. **Clone the repository**:

    ```bash
    git clone https://github.com/your-username/usgs-earthquake-api.git
    cd usgs-earthquake-api
    ```

2. **Create and activate a virtual environment** (optional but recommended):

    ```bash
    python3 -m venv venv
    source venv/bin/activate  
    ```

3. **Install dependencies**:

    ```bash
    pip install -r requirements.txt
    ```

4. **Build the Docker containers**:

   If you're using Docker:

    ```bash
    docker-compose build
    ```

5. **Start the service**:

   You can run the service either using Docker or directly with FastAPI.

    - **Using Docker**:

        ```bash
        docker-compose up
        ```

    - **Directly with FastAPI**:

        ```bash
        fastapi dev
        ```

6. The service will be available at `http://localhost:8000`.

## USGS Earthquake Data Feed

This service extends the [USGS Earthquake Data Feed](https://earthquake.usgs.gov/fdsnws/event/1/) to provide real-time earthquake data. You can read the documentation provided by the USGS for details on the data format and available options.

## Contributions

Feel free to fork this project and submit pull requests. Please ensure your code follows the PEP-8 style guide for Python code and includes tests for new features.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
