from pydantic import BaseModel, EmailStr, constr, ConfigDict

class UserBase(BaseModel):
    name: constr(min_length=2, max_length=50)
    email: EmailStr

class UserCreate(UserBase):
    pass

class UserUpdate(UserBase):
    pass

class UserResponse(UserBase):
    id: int

    model_config = ConfigDict(from_attributes=True)
