import datetime


def calculate_dates(bday: datetime.date, now: datetime.date = None) -> int:
    if now is None:
        now = datetime.date.today()
    delta1 = datetime.datetime(now.year, bday.month, bday.day).date()
    delta2 = datetime.datetime(now.year + 1, bday.month, bday.day).date()

    return ((delta1 if delta1 >= now else delta2) - now).days
