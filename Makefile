CC = elm
SRC = src
UTIL = /home/jcollard/git/elm-util
RESOURCES=$(UTIL)/resources
RTS=$(RESOURCES)/elm-runtime.js
CACHE = cache
BUILD = build
FLAGS = --make --cache-dir=$(CACHE) --build-dir=$(BUILD) --src-dir=$(SRC) --src-dir=$(UTIL)/src
JS_FLAGS = $(BUILD_FLAGS) --only-js
BUILD_FLAGS = $(FLAGS) --runtime=$(RTS)


compile: flyerWindow


Flyer = $(SRC)/Flyer
Flyer.js = $(BUILD)/$(Flyer).js
Flyer.elm = $(Flyer).elm

flyer: $(Flyer.js)
$(Flyer.js): $(Flyer.elm)
	$(CC) $(FLAGS) $(Flyer.elm)

FlyerWindow = $(SRC)/FlyerWindow
FlyerWindow.html = $(BUILD)/$(FlyerWindow).html
FlyerWindow.elm = $(FlyerWindow).elm

flyerWindow: $(FlyerWindow.html)
$(FlyerWindow.html): $(FlyerWindow.elm) $(Flyer.elm)
	$(CC) $(BUILD_FLAGS) $(FlyerWindow.elm)


clean:
	find . -name "*.elmi" -delete
	find . -name "*.elmo" -delete
	find . -name "*.*~" -delete
	rm $(BUILD) -rf
	rm $(CACHE) -rf
