from flask import render_template, request, redirect, url_for
from flask_login import current_user

from application import app, db, login_manager, login_required
from application.reviews.models import Review
from application.reviews.forms import ReviewForm

@app.route("/reviews/", methods=["GET"])
def reviews_index():
    return render_template("reviews/list.html", reviews = Review.query.all())

@app.route("/reviews/new/")
@login_required(role="ANY")
def reviews_form():
    return render_template("reviews/new.html", form = ReviewForm())
  
@app.route("/reviews/", methods=["POST"])
@login_required(role="ANY")
def reviews_create():
    form = ReviewForm(request.form)
  
    if not form.validate():
        return render_template("reviews/new.html", form = form)

  
    t = Review(form.score.data, form.comment.data)
    t.account_id = current_user.id
  
    db.session().add(t)
    db.session().commit()
  
    return redirect(url_for("reviews_index"))