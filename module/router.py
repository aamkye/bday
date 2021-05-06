import os
from datetime import datetime

from fastapi import Body, status, APIRouter
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from pydantic import ValidationError
import motor.motor_asyncio

from module.model import bday
from module.tools import bday_calc

router = APIRouter()
client = motor.motor_asyncio.AsyncIOMotorClient(os.environ["MONGODB_URL"])
db = client.bday


@router.put(
    "/hello/{user_id}",
    response_description="Create user entry.",
    response_model=bday.UserModel)
async def put_user(user_id: str, body: bday.UserModel = Body(...)):
    input_obj = jsonable_encoder(body)
    try:
        _user = dict(
            bday.UserModel(
                _id=input_obj['_id'],
                name=user_id,
                date_of_birth=input_obj['date_of_birth']
            )
        )
    except ValidationError as exc:
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content=jsonable_encoder({"detail": exc.errors()})
        )

    await db.users.insert_one(_user)

    return JSONResponse(status_code=status.HTTP_204_NO_CONTENT)


@router.get(
    "/hello/{user_id}",
    response_description="Get a single user.",
    response_model=bday.UserModel)
async def show_user(user_id: str):
    if (user := await db.users.find_one({"name": user_id})) is not None:
        days = bday_calc.calculate_dates(
            datetime.strptime(
                user['date_of_birth'],
                "%Y-%m-%d"
            ).date()
        )
        if days == 0:
            content = {"message": f"Hello, {user_id}! Happy birthday!"}
        else:
            content = {
                "message": f"Hello, {user_id}! " +
                f"Your birthday is in {days} day(s)"}
        return JSONResponse(status_code=status.HTTP_200_OK, content=content)

    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content=f"User {user_id} not found")


@router.get("/health", response_description="Healthcheck")
async def healthcheck():
    return JSONResponse(
        status_code=status.HTTP_200_OK,
        content="OK")
