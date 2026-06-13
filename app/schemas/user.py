from pydantic import BaseModel, EmailStr, constr

class UserBase(BaseModel):
    name: constr(min_length=2, max_length=50)
    email: EmailStr

class UserCreate(UserBase):
    pass

class UserUpdate(UserBase):
    pass

class UserResponse(UserBase):
    id: int

    class Config:
        from_attributes = True
