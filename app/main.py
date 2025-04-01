from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from . import models, database
from .schemas import UserCreate, UserOut
from .utils import get_password_hash

database.create_db_and_tables()

app = FastAPI()

@app.get("/users", response_model=list[UserOut])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    users = db.query(models.User).offset(skip).limit(limit).all()
    return users

@app.post("/user", response_model=UserOut, status_code=201)
def create_user(user: UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.username == user.username).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    hashed_password = get_password_hash(user.password)
    db_user = models.User(username=user.username, email=user.email, full_name=user.full_name, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# --- Keeping your original USGS API endpoints ---
from usgs_api import UsgsApi
import requests
import json

SAN_FRAN_BAY_AREA = {
    "latitude": 37.770396105,
    "longitude": -122.449777188,
    "maxradiuskm": 100
}

@app.get("/earthquakes")
def get_earthquakes(start_time: str, end_time: str):
    params = {
        "format": "geojson",
        "starttime": start_time,
        "endtime": end_time,
        "minmagnitude": 2.0,
        "latitude": SAN_FRAN_BAY_AREA["latitude"],
        "longitude": SAN_FRAN_BAY_AREA["longitude"],
        "maxradiuskm": 100,
    }
    response = requests.get(UsgsApi.usgs_url, params=params)
    data = response.json()
    return data

@app.get("/earthquakes/felt_reports")
def get_earthquakes_with_felt_reports(start_time: str, end_time: str, min_magnitude: float = 2.0):
    params = {
        "format": "geojson",
        "starttime": start_time,
        "endtime": end_time,
        "minmagnitude": min_magnitude,
        "latitude": SAN_FRAN_BAY_AREA["latitude"],
        "longitude": SAN_FRAN_BAY_AREA["longitude"],
        "maxradiuskm": 100
    }
    response = requests.get(UsgsApi.usgs_url, params=params)
    data = response.json()
    def felt_10_or_more(earthquake):
        return earthquake["properties"]["felt"] is not None and earthquake["properties"]["felt"] >= 10
    b = list(filter(felt_10_or_more, data["features"]))
    data["features"] = b
    return data


