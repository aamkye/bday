import json
import pytest
import requests


@pytest.mark.e2e
def test_good_health_api():
    resp = requests.get("http://localhost:80/health")

    assert resp.status_code == 200


@pytest.mark.e2e
@pytest.mark.parametrize("user, date", [
    ('test', '1992-06-02'),
    ('asdf', '1992-11-02'),
])
def test_good_put_api(user, date):
    params = {
        "date_of_birth": f"{date}"
    }
    resp = requests.put(
        f"http://localhost:80/hello/{user}",
        data=json.dumps(
            params,
            indent=4))

    assert resp.status_code == 204


@pytest.mark.e2e
@pytest.mark.parametrize("user, date", [
    ('test1', '1992-06-02'),
    ('asdf', '1992.11.02'),
])
def test_bad_put_api(user, date):
    params = {
        "date_of_birth": f"{date}"
    }
    resp = requests.put(
        f"http://localhost:80/hello/{user}",
        data=json.dumps(
            params,
            indent=4))

    assert resp.status_code == 422


@pytest.mark.e2e
@pytest.mark.parametrize("user", [
    ('test'),
    ('asdf'),
])
def test_good_get_api(user):
    resp = requests.get(f"http://localhost:80/hello/{user}")

    assert resp.status_code == 200
    assert user in resp.text


@pytest.mark.e2e
@pytest.mark.parametrize("user", [
    ('testqwer'),
    ('asdfuiop'),
])
def test_bad_get_api(user):
    resp = requests.get(f"http://localhost:80/hello/{user}")

    assert resp.status_code == 404
