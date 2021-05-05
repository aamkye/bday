from datetime import datetime
import pytest

from . import bday_calc


@pytest.mark.unit
@pytest.mark.parametrize("bday, today, expected", [
    ('1992-06-02', '2020-05-31', 2),
    ('1992-06-02', '2020-06-01', 1),
    ('1992-06-02', '2020-06-02', 0),
    ('1992-06-02', '2020-06-03', 364),
    ('1992-06-02', '2020-06-04', 363),
])
def test_calculate_dates(bday, today, expected):
    bday = datetime.strptime(bday, "%Y-%m-%d").date()
    today = datetime.strptime(today, "%Y-%m-%d").date()

    days = bday_calc.calculate_dates(bday, today)
    assert days == expected
