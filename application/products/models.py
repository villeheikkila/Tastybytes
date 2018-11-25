from application import db
from application.models import Base
from sqlalchemy.sql import text

class Product(Base):

    name = db.Column(db.String(144), nullable=False)
    producer = db.Column(db.String(144), nullable=False)
    public = db.Column(db.Boolean, nullable=False)

    account_id = db.Column(db.Integer, db.ForeignKey('account.id'), nullable=False)

    def __init__(self, name, producer):
        self.name = name
        self.producer = producer
        self.public = False

    @staticmethod
    def remove_product(id):
        print("poistetaan: " + id)
        stmt = text("DELETE FROM product WHERE (Product.id = :id)").params(id=id)
        db.engine.execute(stmt)