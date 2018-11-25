from application import db
from application.models import Base
from sqlalchemy.sql import text

class Review(Base):

    score = db.Column(db.String(144), nullable=False)
    comment = db.Column(db.String(500), nullable=False)

    account_id = db.Column(db.Integer, db.ForeignKey('account.id'), nullable=False)

    def __init__(self, score, comment):
        self.score = score
        self.comment = comment
