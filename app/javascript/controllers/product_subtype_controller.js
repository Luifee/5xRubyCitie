import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "template", "adding" ]

  add_sku(event) {
    event.preventDefault();
    let content = this.templateTarget.innerHTML.replace(/New_data/g, new Date().getTime());
    this.addingTarget.insertAdjacentHTML('beforebegin', content);
  }
  
  connect() {
  }
}
