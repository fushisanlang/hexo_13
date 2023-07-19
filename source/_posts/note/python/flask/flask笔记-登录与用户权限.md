---
title: flask笔记-登录与用户权限
date: 2016-9-22
updated: 2016-9-23
tags:
  - python
  - flask
categories:
  - note
abbrlink: 615cc1a2
---
# flask笔记-登录与用户权限

用户认证模块 | Flask-Login



1.1 准备用于登陆的用户模型

模型继承UserMixin


```python
from app import db
from werkzeug.security import generate_password_hash,check_password_hash
from flask_login import UserMixin
from . import login_manger

@login_manger.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

class Role(db.Model):
    __tablename__ = 'roles'
    id = db.Column(db.Integer,primary_key=True)
    name = db.Column(db.String(64),unique=True)
    users = db.relationship('User',backref='role')
    def __repr__(self):
        return '<Role %r>'%self.name

class User(UserMixin,db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer,primary_key=True)
    username = db.Column(db.String(64),unique=True,index=True)
    password_hash = db.Column(db.String(128))
    role_id = db.Column(db.Integer, db.ForeignKey('roles.id'))
    email = db.Column(db.String(128))

    @property
    def password(self):
        raise AttributeError('密码不可读')

    @password.setter
    def password(self,password):
        self.password_hash = generate_password_hash(password)

    def verify_password(self,password):
        return check_password_hash(self.password_hash,password)

    def __repr__(self):
        return '<Role %r>'%self.username
```


初始化登陆



```
from flask import Flask,render_template
from flask_sqlalchemy import SQLAlchemy
from config import Config
from flask_login import LoginManager

db = SQLAlchemy()
login_manger = LoginManager()
login_manger.session_protection = 'strong'
login_manger.login_view = 'auth.login'

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    Config.init_app(app)
    db.init_app(app)
    login_manger.init_app(app)
    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint)
    from .auth import auth as auth_blueprint
    app.register_blueprint(auth_blueprint,url_prefix='/auth')
    return app
```


1.2 保护路由



```
from datetime import datetime
from  flask import render_template,session,redirect,url_for
from . import main
from .forms import NameForm
from .. import db
from .. import models
from flask_login import login_required


@main.route('/',methods=['GET','POST'])
@login_required
def index():
    form = NameForm()
    if form.validate_on_submit():
        session['name'] = form.name.data
        session['ip'] = form.ip.data
        form.name.data=''
        form.ip.data=''
        return redirect(url_for('.index'))
    return render_template('index.html',form=form,name=session.get('name'),ip=session.get('ip'))
```


1.3 登陆页面

在前端可以使用current_user对象


```
{% extends 'base.html' %}
{% block head %}{{ super() }}{% endblock %}
{% block title %}登陆{% endblock %}
{% block body %}
    <h1>

    </h1>
    {% if current_user.is_authenticated %}
        <h1>欢迎{{ current_user.username }}</h1>
        <p><a href="{{ url_for('auth.logout') }}">登出</a></p>
    {% else %}
        <h1>登录页面</h1>
        <form method="post" action="">
                {{ form.hidden_tag() }}
            <p>{{ form.email.label }}{{ form.email }}</p>
            <p>{{ form.password.label }}{{ form.password }}</p>
            <p>{{ form.sumbit }}</p>
            <p>{{ form.remember_me.label }}{{ form.remember_me }}</p>
        </form>
        <p><a href="{{ url_for('auth.register') }}">注册</a></p>
    {% endif %}
{% endblock %}
```



1.4 登入登出注册用户

login_user('用户模型对象','True/False')

logout_user()

```
from flask import render_template,redirect,request,url_for,flash
from flask_login import login_user,login_required,logout_user
from . import auth
from ..models import User,db
from .forms import LoginForm,RegistrationForm

@auth.route('/login',methods=['GET','POST'])
def login():
    form = LoginForm()
    user = User.query.filter_by(email=form.email.data).first()
    if user is not None and user.verify_password(form.password.data):
        login_user(user,form.remember_me.data)
        return redirect(url_for('main.index'))
    return render_template('auth/login.html',form=form)

@auth.route('/logout')
@login_required
def logout():
    logout_user()
    flash('你已经登出了')
    return redirect(url_for('main.index'))


@auth.route('/register',methods=['GET','POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        user = User(email=form.email.data,username=form.username.data,password=form.password1.data)
        db.session.add(user)
        db.session.commit()
        return redirect(url_for('auth.login'))
    return render_template('auth/register.html',form=form)
```



 

2、用户角色权限

还是主要靠程序逻辑来做权限

2.1 在角色模型中添加权限、赋予角色、角色验证


```
from app import db
from werkzeug.security import generate_password_hash,check_password_hash
from flask_login import UserMixin,AnonymousUserMixin
from . import login_manger

@login_manger.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

class Permission:
    FLLOW = 0x01
    COMMENT = 0x02
    WRITE_ARTICLES = 0x04
    MODERATE_COMMENTS = 0x08
    ADMINISTER = 0x80

class Role(db.Model):
    __tablename__ = 'roles'
    id = db.Column(db.Integer,primary_key=True)
    name = db.Column(db.String(64),unique=True)
    default = db.Column(db.Boolean,default=False,index=True)
    permissions = db.Column(db.Integer)
    users = db.relationship('User',backref='role')

    #创建数据库角色
    @staticmethod
    def insert_roles():
        roles = {
            'User':(Permission.FLLOW|Permission.COMMENT|Permission.WRITE_ARTICLES,True),
            'Admin':(0xff,False)
        }
        for r in roles:
            role = Role.query.filter_by(name = r).first()
            if role is None:
                role = Role(name=r)
            role.permissions = roles[r][0]
            role.default=roles[r][1]
            db.session.add(role)
            db.session.commit()

    def __repr__(self):
        return '<Role %r>'%self.name

class User(UserMixin,db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer,primary_key=True)
    username = db.Column(db.String(64),unique=True,index=True)
    password_hash = db.Column(db.String(128))
    role_id = db.Column(db.Integer, db.ForeignKey('roles.id'))
    email = db.Column(db.String(128))

    #创建的新用户默认是用户权限
    def __init__(self,**kwargs):
        super(User,self).__init__(**kwargs)
        self.role = Role.query.filter_by(default=True).first()
    
    @property
    def password(self):
        raise AttributeError('密码不可读')

    @password.setter
    def password(self,password):
        self.password_hash = generate_password_hash(password)

    def verify_password(self,password):
        return check_password_hash(self.password_hash,password)

    #角色验证
    def can(self,permissions):
        return self.role is not None and (self.role.permissions & permissions) == permissions

    def is_admin(self):
        return self.can(Permission.ADMINISTER)

    def __repr__(self):
        return '<User %r>'%self.username

#匿名角色，主要为了与上面统一
class AnonymousUser(AnonymousUserMixin):
    def can(self,permissions):
        return False

    def is_admin(self):
        return False

login_manger.anonymous_user = AnonymousUser
```


python manage.py shell

Role.insert_roles()

 2.2 定义用户权限验证装饰器


```
from functools import wraps
from flask import abort
from flask_login import current_user
from .models import Permission

def permission_required(permission):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args,**kwargs):
            if not current_user.can(permission):
                abort(403)
            return f(*args,**kwargs)
        return decorated_function
    return decorator

def admin_required(f):
    return permission_required(Permission.ADMINISTER)(f)
```


2.3 给需要权限访问的页面加装饰器


```
from datetime import datetime
from  flask import render_template,session,redirect,url_for
from . import main
from .forms import NameForm
from .. import db
from .. import models
from flask_login import login_required
from ..decorators import admin_required,permission_required
from ..models import Permission

@main.route('/',methods=['GET','POST'])
@login_required
def index():
    form = NameForm()
    if form.validate_on_submit():
        session['name'] = form.name.data
        session['ip'] = form.ip.data
        form.name.data=''
        form.ip.data=''
        return redirect(url_for('.index'))
    return render_template('index.html',form=form,name=session.get('name'),ip=session.get('ip'))


@main.route('/admin')
@login_required
@admin_required
def admin_only():
    return render_template('admin.html')


@main.route('/user')
@login_required
@permission_required(Permission.WRITE_ARTICLES)
def user_page():
    return render_template('user.html')
```