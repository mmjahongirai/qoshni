"""SQLAlchemy declarative base shared by ORM models and Alembic."""

from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    """Application ORM declarative base."""


metadata = Base.metadata
