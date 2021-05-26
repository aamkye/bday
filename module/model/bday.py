import datetime
from typing import Optional
from bson import ObjectId

from pydantic import BaseModel, Field, validator


class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, val):
        if not ObjectId.is_valid(val):
            raise ValueError("Invalid objectid")
        return ObjectId(val)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")


class InputModel(BaseModel):
    date_of_birth: str = Field(...)

    @validator('date_of_birth')
    def validate_date(cls, val):
        if datetime.datetime.strptime(
                val, "%Y-%m-%d").date() >= datetime.date.today():
            raise ValueError("Date is from the future or is today.")
        return val

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        fields = {
            "date_of_birth": "date_of_birth"
        }
        schema_extra = {
            "example": {
                "date_of_birth": "1992-06-22",
            }
        }


class UserModel(InputModel):
    _id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    name: Optional[str] = Field(default=None)

    @validator('name', always=True)
    def validate_name(cls, val):
        if val is None:
            return None
        if not val.isalpha():
            raise ValueError(
                "Invalid charactes in username, only alphas are allowed. ")
        return val
