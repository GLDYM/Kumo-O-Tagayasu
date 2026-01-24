How to run the server:
- Run install-server.ps1 or install-server.sh, depanding on your OS.
  - This script will download Pakku from https://github.com/juraj-hrivnak/Pakku/releases/download/v1.3.2/pakku.jar
  - Then use Pakku to build the serverpack.
  - Next unzip the serverpack into server/ folder and install forge in it.
- Waiting build complete, about lasting 5 mins to 20 mins. the server will build in server/ folder.
- Check the number of mods in server/mods/. If less than 220, run installer script again, or download the full-serverpack.
- Configure the server.properties and what you want.
- Run run.bat or run.sh in the server folder, depanding on your OS.

If you encounter network problems，try to build local,
or visit Github https://github.com/GLDYM/Kumo-O-Tagayasu to download the full server-pack.

The files in MCDR/ folder is prepared for MCDReforged.

put handler/ and server/ in the same folder，configures config.yml：

handler: kots_handler
custom_handlers:
- handlers.kots_handler.KOTSHandler

To MCDReforged output correctly. 