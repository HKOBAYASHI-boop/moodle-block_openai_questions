const init = (Y, courseid, wwwroot) => {
    document.querySelectorAll('.block_openai_questions-question .block_openai_questions-delete').forEach(button => {
        button.addEventListener('click', e => {
            removeQuestion(e.target.closest('.block_openai_questions-question'))
        })
    })

    document.querySelector('#addToQBank').addEventListener('click', async e => {
        e.preventDefault()
        const button = e.currentTarget
        if (button.disabled) return
        const originalValue = button.value
        const originalOpacity = button.style.opacity
        const originalPointerEvents = button.style.pointerEvents
        const previousError = document.querySelector('#block_openai_questions-saveerror')
        if (previousError) previousError.hidden = true
        button.disabled = true
        button.style.opacity = '0.5'
        button.value = "Please wait..."
        button.style.pointerEvents = 'none'

        let errorMessage = 'The save result could not be confirmed. Your generated questions are still available below. Please check the question bank before trying again.'
        try {
            const questions = buildQuestionObj()
            const expectedCount = Object.keys(questions.questions).length
            if (expectedCount === 0) {
                errorMessage = 'There are no questions to save.'
                throw new Error(errorMessage)
            }
            const response = await fetch(`${wwwroot}/blocks/openai_questions/api/question.php`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(questions)
            })
            if (!response.ok) {
                errorMessage = `Questions could not be saved (HTTP ${response.status}). Your generated questions are still available below. Please check the question bank before trying again.`
                throw new Error(errorMessage)
            }
            const result = await response.json()
            if (result.response !== 200 || !result.data || result.data.savedcount !== expectedCount) {
                errorMessage = 'The saved questions could not be confirmed. Please check the question bank before trying again.'
                throw new Error(errorMessage)
            }
            window.location.href = `${wwwroot}/question/edit.php?courseid=${courseid}`
        } catch (error) {
            let notice = document.querySelector('#block_openai_questions-saveerror')
            if (!notice) {
                notice = document.createElement('div')
                notice.id = 'block_openai_questions-saveerror'
                notice.className = 'alert alert-danger'
                notice.setAttribute('role', 'alert')
                button.parentNode.insertBefore(notice, button)
            }
            notice.textContent = errorMessage
            notice.hidden = false
            button.disabled = false
            button.value = originalValue
            button.style.opacity = originalOpacity
            button.style.pointerEvents = originalPointerEvents
        }
    })

    document.querySelectorAll('.block_openai_questions-markCorrectButton').forEach(button => {
        button.addEventListener('click', (e) => {
            // If the AI didn't mark a correct answer for this question, this will fail
            // let's just catch it and ignore that
            try {
                e.target.closest('.block_openai_questions-text-container').querySelector('.block_openai_questions-correct').classList.remove('block_openai_questions-correct')
            } catch (e) {}
            e.target.parentElement.querySelector('input').classList.add('block_openai_questions-correct')
        })
    })
}

const buildQuestionObj = () => {
    let questions = {'questions': {}}
    document.querySelectorAll('.block_openai_questions-question').forEach(questionElem => {
        let answers = {}
        let correct = 'A';
        questionElem.querySelectorAll('input').forEach(answer => {
            if (answer.classList.contains('block_openai_questions-correct')) {
                correct = answer.dataset.qid
            }
            answers[answer.dataset.qid] = answer.value.trim()
        })
        questions['questions'][questionElem.querySelector('textarea').value] = {}
        questions['questions'][questionElem.querySelector('textarea').value]['answers'] = answers
        questions['questions'][questionElem.querySelector('textarea').value]['correct'] = correct
    })
    questions['courseid'] = document.querySelector('#courseid').value;
    questions['qtype'] = document.querySelector('#qtype').value;

    return questions
}

const removeQuestion = (elem) => {
    elem.style.opacity = '0'
    elem.style.maxHeight = elem.clientHeight + 'px'
    window.setTimeout(() => {

        elem.style.maxHeight = '0px'
        elem.style.padding = '0'
        elem.style.marginTop = '-1rem'

        window.setTimeout(() => {
            elem.remove()
        }, 400)

    }, 150)
}
