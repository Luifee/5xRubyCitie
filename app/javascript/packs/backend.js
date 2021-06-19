// import Rails from "@rails/ujs"
// import Turbolinks from "turbolinks"
// import * as ActiveStorage from "@rails/activestorage"

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()

// enable action text
require("trix")
require("@rails/actiontext")

// Rails.start()
// Turbolinks.start()
// ActiveStorage.start()

import "controllers";

import "stylesheets/backend";
import "stylesheets/shared";
import "scripts/backend";
import "scripts/shared";
