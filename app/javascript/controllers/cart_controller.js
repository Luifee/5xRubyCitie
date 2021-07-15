import { Controller } from "stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "count" ]

  updateCart(evt) {
    evt.preventDefault();
    
    let data = evt.detail;
    this.countTarget.innerText = `(${data.item_count})`;
  }
}
