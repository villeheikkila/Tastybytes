from flask import render_template, request, redirect, url_for
from flask_login import current_user

from application import app, db, login_manager, login_required
from application.products.models import Product
from application.products.forms import ProductForm

@app.route("/products/", methods=["GET"])
def products_index():
    return render_template("products/list.html", products = Product.query.all())

  
@app.route("/products/new/")
@login_required(role="ANY")
def products_form():
    return render_template("products/new.html", form = ProductForm())


@app.route("/products/<product_id>/", methods=["POST"])
@login_required(role="ANY")
def products_set_public(product_id):

    t = Product.query.get(product_id)
    if t.account_id != current_user.id:
         return login_manager.unauthorized

    t.public = True
    db.session().commit()

    return redirect(url_for("products_index"))

## This doesn't work.
@app.route("/products/<product_id>/", methods=["POST"])
@login_required(role="ANY")
def product_remove(product_id):

    t = Product.query.get(product_id)
    if t.account_id != current_user.id:
         return login_manager.unauthorized

    Product.remove_product(product_id)
    db.session().commit()
  
    return redirect(url_for("products_index"))
  
@app.route("/products/", methods=["POST"])
@login_required(role="ANY")
def products_create():
    form = ProductForm(request.form)
  
    if not form.validate():
        return render_template("products/new.html", form = form)
  
    t = Product(form.name.data, form.producer.data)
    t.public = form.public.data
    t.account_id = current_user.id
  
    db.session().add(t)
    db.session().commit()
  
    return redirect(url_for("products_index"))