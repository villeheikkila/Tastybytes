from flask import render_template, request, redirect, url_for
from flask_login import login_required, current_user

from application import app, db
from application.tasks.models import Task
from application.tasks.forms import TaskForm


@app.route("/tasks/", methods=["GET"])
def tasks_index():
    return render_template("tasks/list.html", tasks = Task.query.all())

  
@app.route("/tasks/new/")
@login_required
def tasks_form():
    return render_template("tasks/new.html", form = TaskForm())

  
@app.route("/tasks/<task_id>/", methods=["POST"])
@login_required
def tasks_set_done(task_id):

    t = Task.query.get(task_id)
    t.done = True
    db.session().commit()
  
    return redirect(url_for("tasks_index"))

  
@app.route("/tasks/", methods=["POST"])
@login_required
def tasks_create():
    form = TaskForm(request.form)
  
    if not form.validate():
        return render_template("tasks/new.html", form = form)
  
    t = Task(form.name.data)
    t.done = form.done.data
    t.account_id = current_user.id
  
    db.session().add(t)
    db.session().commit()
  
    return redirect(url_for("tasks_index"))