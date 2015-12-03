# mindmup
Mindmup v2

#Editing toolbar font icons
	- use iDraw, open fontcustom/iDraw/toolbar-icons.idraw
	- each icon is a layer, edit or add layers, then export layers. Make sure all layers are visible

#Rebuild Toolbar font
1. Install font custom - see instructions here: http://fontcustom.com/
2. Recompile using:
	fontcustom compile
	fontcustom watch <-- watched for changes and recompiles automatically


# Setup Instructions

1. Install ruby 2.2.3 and bundle gem
2. bundle install
3. npm install


#Deploy to environment
e.g. Staging
sh deploy.sh staging