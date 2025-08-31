import re

from typing_extensions import override

from mcdreforged.handler.impl.forge_handler import ForgeHandler
from mcdreforged.handler.impl.abstract_minecraft_handler import AbstractMinecraftHandler

class KOTSHandler(ForgeHandler):
	def get_name(self) -> str:
		return 'kots_handler'

	@override
	def parse_server_stdout(self, text: str):
		result = super(AbstractMinecraftHandler, self).parse_server_stdout(text)
		parser = re.compile(r'(\[Not Secure] )?<(?P<name>[^>]+)> (?P<message>.*)')
		parsed = parser.fullmatch(result.content)
		if parsed is not None and self._verify_player_name(parsed['name'].split(" ", 1)[0]):
			result.player, result.content = parsed['name'].split(" ", 1)[0], parsed['message']
		return result

	@override
	def parse_player_left(self, info):
		if not info.is_user:
			if (m := re.compile(r'(?P<name>.+) left the game').fullmatch(info.content)) is not None:
				if self._verify_player_name(m['name'].split(" ", 1)[0]):
					return m['name']
		return None

if __name__ == '__main__':
	handler = KOTSHandler()
	test = handler.parse_server_stdout('[01:02:03] [Server thread/INFO]: <PlayerName (虚空)> Message')
	test2 = handler.parse_player_left(handler.parse_server_stdout('[10:43:09] [Server thread/INFO] [minecraft/MinecraftServer]: Polaris_Light (虚空) left the game'))
	print(test.player)
	print(test2)