import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "template", "adding" ]

  add_sku(event) {
    event.preventDefault();
    let content = this.templateTarget.innerHTML.replace(/New_data/g, new Date().getTime());
    this.addingTarget.insertAdjacentHTML('beforebegin', content);
  }
  
  remove_sku(event) {
    event.preventDefault();
    let wrapper = event.target.closest('.nested-fields');
    if (wrapper.dataset.newRecord == 'true') {
      wrapper.remove(); 
    } else {
      wrapper.querySelector("input[name*='_destroy']").value = 1;
      wrapper.style.display = 'none';
    }
  }
}
