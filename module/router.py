import os

from fastapi import Body, HTTPException, status, APIRouter
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from pydantic import ValidationError
import motor.motor_asyncio
from datetime import datetime

from module.model import bday
from module.tools import bdayCalc

router = APIRouter()
client = motor.motor_asyncio.AsyncIOMotorClient(os.environ["MONGODB_URL"])
db = client.bday

@router.put("/hello/{user_id}", response_description="Create user entry.", response_model=bday.UserModel)
async def put_user(user_id: str, body: bday.UserModel = Body(...)):
    inputObj = jsonable_encoder(body)
    try:
        _user = dict(bday.UserModel(_id=inputObj['_id'], name=user_id, dateOfBirth=inputObj['dateOfBirth']))
    except ValidationError as e:
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content=jsonable_encoder({"detail": e.errors()})
        )

    await db.users.insert_one(_user)

    return JSONResponse(status_code=status.HTTP_204_NO_CONTENT)

@router.get("/hello/{user_id}", response_description="Get a single user.", response_model=bday.UserModel)
async def show_user(user_id: str):
    if (user := await db.users.find_one({"name": user_id})) is not None:
        days = bdayCalc.calculate_dates(datetime.strptime(user['dateOfBirth'], "%Y-%m-%d").date())
        if days == 0:
            content={ "message": f"Hello, {user_id}! Happy birthday!" }
        else:
            content={ "message": f"Hello, {user_id}! Your birthday is in {days} day(s)"}
        return JSONResponse(status_code=status.HTTP_200_OK, content=content)

    raise HTTPException(status_code=404, detail=f"User {user_id} not found")

@router.get("/health", response_description="Healthcheck")
async def healthcheck():
    return JSONResponse(status_code=status.HTTP_200_OK, content="OK")
