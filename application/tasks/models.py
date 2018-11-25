from application import db
from application.models import Base

class Task(Base):

    name = db.Column(db.String(144), nullable=False)
    producer = db.Column(db.String(144), nullable=False)
    done = db.Column(db.Boolean, nullable=False)

    account_id = db.Column(db.Integer, db.ForeignKey('account.id'), nullable=False)

    def __init__(self, name, producer):
        self.name = name
        self.producer = producer
        self.done = False