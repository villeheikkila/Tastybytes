from flask_wtf import FlaskForm
from wtforms import BooleanField, StringField, validators

class TaskForm(FlaskForm):
    name = StringField("Tuotteet nimi:", [validators.Length(min=2)])
    producer = StringField("Valmistaja:", [validators.Length(min=2)])
    done = BooleanField("Done")
  
    class Meta:
        csrf = False