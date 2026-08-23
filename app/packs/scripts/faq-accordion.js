import ahoy from "ahoy.js";

const accordionPosts = document.querySelectorAll(".accordion-collapse")

accordionPosts.forEach((element) => {
  element.addEventListener('show.bs.collapse', event => {
    const id = event.target.id
    const postId = id.substring('collapsePost'.length)

    const button = document.querySelector(`button[data-bs-target="#${id}"]`)
    const questionViewEventName = button.getAttribute('data-bs-event-view-name')

    ahoy.track(questionViewEventName, {language: "JavaScript", post_id: postId})
  })
});