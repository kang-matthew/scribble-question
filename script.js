document.addEventListener("DOMContentLoaded", function () {

    document.querySelectorAll('.hint').forEach(button => {
        button.addEventListener("click", function () {

            const question = this.closest(".question");
            question.querySelector(".hint-container").style.display = "block"
        })
    })

    document.querySelectorAll(".submit").forEach(button => {
        button.addEventListener("click", function () {

            const question = this.closest(".question");

            let isQuestionCorrect = true

            question.querySelectorAll(".options").forEach(problem => {

                resetProblem(problem)

                const isProblemCorrect = Array.from(problem.querySelectorAll("input")).every(input => {
                    const isCorrect = input.closest("label").classList.contains("correct")
                    const isChecked = input.checked
                    return isChecked === isCorrect
                })

                isQuestionCorrect = isQuestionCorrect && isProblemCorrect

                problem.querySelectorAll("input:checked").forEach(input => {
                    input.closest("label").style.border = `2px solid ${isProblemCorrect ? "green" : "red"}`
                })

            })

            if (isQuestionCorrect) {
                question.querySelector("#incorrect-icon").style.display = "none"
                question.querySelector("#correct-icon").style.display = "block"
                question.querySelector(".hint-container").style.display = "none"
                question.querySelector(".explanation-container").style.display = "block"
                question.querySelector(".hint").style.display = "none"
            } else {
                question.querySelector("#incorrect-icon").style.display = "block"
                question.querySelector("#correct-icon").style.display = "none"
                question.querySelector(".explanation-container").style.display = "none"
                question.querySelector(".hint").style.display = "block"
            }
        })
    })
});

/**
 * Resets problem by uncoloring all
 */
function resetProblem(problem) {
    problem.querySelectorAll("input").forEach(input => {
        input.closest("label").style.border = "2px solid gray"
    })
}