import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

import "controllers";

import "stylesheets/frontend";
import "stylesheets/shared";
import "scripts/frontend";
import "scripts/shared";

require("trix")
require("@rails/actiontext")
import "controllers"
