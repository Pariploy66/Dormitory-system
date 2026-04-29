from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    external_api_base_url: str
    external_api_key: str

    nestjs_base_url: str = "http://192.168.20.240:3000"
    internal_api_key: str

    poll_interval_seconds: int = 30
    port: int = 8000


settings = Settings()
