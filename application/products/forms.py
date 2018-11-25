from flask_wtf import FlaskForm
from wtforms import BooleanField, StringField, validators

class ProductForm(FlaskForm):
    name = StringField("Tuotteet nimi:", [validators.Length(min=2)])
    producer = StringField("Valmistaja:", [validators.Length(min=2)])
    public = BooleanField("Julkinen")
  
    class Meta:
        csrf = False