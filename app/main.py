from fastapi import FastAPI
from usgs_api import UsgsApi
import requests
import json

app = FastAPI()

SAN_FRAN_BAY_AREA = {
        "latitude": 37.770396105,
        "longitude": -122.449777188,
        "maxradiuskm": 100
}
#
# @app.get("/api_url")
# def get_api_url():
#          return { UsgsApi.usgs_url}

"""A new endpoint to retrieve all earthquakes M2.0+ for the San Francisco Bay Area during a
specific time range."""

@app.get("/earthquakes")
def get_earthquakes(start_time: str, end_time: str):
    params = {
        "format": "geojson",  # Response format
        "starttime": start_time,
        "endtime": end_time,
        "minmagnitude": 2.0,
        "latitude": SAN_FRAN_BAY_AREA["latitude"],
        "longitude": SAN_FRAN_BAY_AREA["longitude"],
        "maxradiuskm": 100,
    }

    response = requests.get(UsgsApi.usgs_url, params=params)
    data = response.json()

    print (response.request.url)
    return data

"""A new endpoint to retrieve all earthquakes M2.0+ that have 10+ felt reports for the San
    Francisco Bay Area during a specific time range."""

@app.get("/earthquakes/felt_reports")
def get_earthquakes_with_felt_reports(start_time: str, end_time: str,
        min_magnitude: float = 2.0):

    params = {
        "format": "geojson",
        "starttime": start_time,
        "endtime": end_time,
        "minmagnitude": min_magnitude,
        "latitude": SAN_FRAN_BAY_AREA["latitude"],
        "longitude": SAN_FRAN_BAY_AREA["longitude"],
        "maxradiuskm": 100
    }

    # Send the request to the USGS Earthquake API
    response = requests.get(UsgsApi.usgs_url, params=params)
    data = response.json()

    def felt_10_or_more(earthqauke):

       return earthqauke["properties"]["felt"] is not None and earthqauke["properties"]["felt"] >= 10
    print(data["features"])

    b = list (filter(felt_10_or_more,data["features"]))
    data["features"] = b

    return data


