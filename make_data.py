#!/usr/bin/env python3

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from faker import Faker
import json
from pathlib import Path


def start():
    parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        "-n", "--number", dest="number", default=1000, help="number of tuples")
    parser.add_argument(
        "-o", "--output", dest="output", default=".", help="output directory")
    args = parser.parse_args()

    faker = Faker()

    to_change = []
    to_change_num = int(args.number / 10)
    if to_change_num == 0:
        to_change_num = 1

    changes_num = int(args.number / 2)
    if changes_num == 0:
        changes_num = 1

    output = Path(args.output)

    with open(output / "profiles.jsonl", "w") as file:
        for i in range(args.number):
            profile = {
                "id": faker.uuid4(),
                "first_name": faker.first_name(),
                "last_name": faker.last_name(),
                "date_of_birth": faker.date(pattern="%Y-%m-%d"),
                "place_of_birth":
                    "{0}, {1}".format(faker.country(), faker.city()),
                "company": faker.company(),
                "job_title": faker.job(),
                "phone": faker.phone_number(),
                "email": faker.email()
            }

            if len(to_change) == 0 or faker.random_int(min=0, max=args.number) < to_change_num:
                to_change.append(profile["id"])

            json.dump(profile, file)
            file.write("\n")

    with open(output / "changes.jsonl", "w") as file:
        max = len(to_change) - 1
        for i in range(changes_num):
            data = {
                "id": to_change[faker.random_int(min=0, max=max)]
            }

            what = faker.random_int(min=0, max=2)
            if what == 0:
                data["company"] = faker.company()
            elif what == 1:
                data["phone"] = faker.phone_number()
            elif what == 2:
                data["email"] = faker.email()

            json.dump(data, file)
            file.write("\n")

if __name__ == "__main__":
    start()
