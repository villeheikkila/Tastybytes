from application import db
from application.models import Base
from sqlalchemy.sql import text

class Product(Base):

    name = db.Column(db.String(144), nullable=False)
    producer = db.Column(db.String(144), nullable=False)
    done = db.Column(db.Boolean, nullable=False)

    account_id = db.Column(db.Integer, db.ForeignKey('account.id'), nullable=False)

    def __init__(self, name, producer):
        self.name = name
        self.producer = producer
        self.done = False

    @staticmethod
    def removeProduct(id):
        print("poistetaan: " + id)
        stmt = text("DELETE * FROM Products WHERE (Product.id = :id)").params(id=id)
        db.engine.execute(stmt)