import re

from typing_extensions import override

from mcdreforged.handler.impl.forge_handler import ForgeHandler

class KOTSHandler(ForgeHandler):
	def get_name(self) -> str:
		return 'kots_handler'
  
	@classmethod
	@override
	def _verify_player_name(cls, name: str):
		return true