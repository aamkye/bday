import pytest

from . import bday

@pytest.mark.unit
@pytest.mark.parametrize("_id, name, date_of_birth", [
    ('507f1f77bcf86cd799439011', 'asdf', "2020-06-22"),
    ('507f1f77bcf86cd799439011', 'qwer', "2020-06-22"),
    ('507f1f77bcf86cd799439011', 'zxcv', "2020-06-22"),
    ('507f1f77bcf86cd799439011', 'uiop', "2020-06-22"),
    ('507f1f77bcf86cd799439011', 'vbnm', "2020-06-22"),
])
def test_good_user_model(_id, name, date_of_birth):
    assert bday.UserModel(
        _id=_id,
        name=name,
        date_of_birth=date_of_birth
    )

@pytest.mark.unit
@pytest.mark.parametrize("_id, name, date_of_birth", [
    ('507f1f77bcf86cd7994390', 'asdf', "2020-06-22"),
    ('$$507f1f77bcf86c99439011', 'qwer', "2020-06-22"),
    ('7f1f77bcf86cd799439011-=', 'zxcv', "2020-06-22"),
    ('507f1f77bcf867994390110', 'uiop', "2020-06-22"),
    ('507f1f77f86cd799439011', 'vbnm', "2020-06-22"),
])
def test_bad_id_user_model(_id, name, date_of_birth):
    with pytest.raises(Exception, match="Invalid objectid"):
        assert bday.UserModel(
            _id=_id,
            name=name,
            date_of_birth=date_of_birth
        )

@pytest.mark.unit
@pytest.mark.parametrize("_id, name, date_of_birth", [
    ('507f1f77bcf86cd799439011', 'asdf1', "2020-06-22"),
    ('507f1f77bcf86cd799439011', '$qwer', "2020-06-22"),
    ('507f1f77bcf86cd799439011', '1zxcv', "2020-06-22"),
    ('507f1f77bcf86cd799439011', 'uiop^', "2020-06-22"),
    ('507f1f77bcf86cd799439011', 'vbnm_', "2020-06-22"),
])
def test_bad_name_user_model(_id, name, date_of_birth):
    with pytest.raises(Exception, match="Invalid charactes in username"):
        assert bday.UserModel(
            _id=_id,
            name=name,
            date_of_birth=date_of_birth
        )

@pytest.mark.unit
@pytest.mark.parametrize("_id, name, date_of_birth", [
    ('507f1f77bcf86cd799439011', 'qwer', "2030-06-22"),
    ('507f1f77bcf86cd799439011', 'vbnm', "3020-06-22"),
])
def test_future_date_user_model(_id, name, date_of_birth):
    with pytest.raises(Exception, match="Date is from the future or is today"):
        assert bday.UserModel(
            _id=_id,
            name=name,
            date_of_birth=date_of_birth
        )

@pytest.mark.unit
@pytest.mark.parametrize("_id, name, date_of_birth", [
    ('507f1f77bcf86cd799439011', 'asdf', "2020.06.22"),
    ('507f1f77bcf86cd799439011', 'zxcv', "2020.06-22"),
    ('507f1f77bcf86cd799439011', 'uiop', "2020-06.22"),
])
def test_bad_date_user_model(_id, name, date_of_birth):
    with pytest.raises(Exception, match="does not match format"):
        assert bday.UserModel(
            _id=_id,
            name=name,
            date_of_birth=date_of_birth
        )
