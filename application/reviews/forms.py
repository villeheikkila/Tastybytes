from flask_wtf import FlaskForm
from wtforms import BooleanField, StringField, validators

class ReviewForm(FlaskForm):
    score = StringField("Arvosana:", [validators.Length(min=1)])
    comment = StringField("Kommentti:", [validators.Length(min=2)])
  
    class Meta:
        csrf = False