// check comment start

let comentSubmitBtn = document.querySelectorAll('.js_comment_submit');

[].forEach.call(comentSubmitBtn, function (e) {
	e.addEventListener('click', checkValue, false)
});

function checkValue() {

	if (this.previousElementSibling.children[0].value !== '') {
		this.previousElementSibling.style.borderColor = '#959595';
		this.previousElementSibling.children[0].value = '';
	} else {
		this.previousElementSibling.style.borderColor = 'red';
	}
}

// add comment start

let addBtnComment = document.querySelectorAll('.js_add_comment');

[].forEach.call(addBtnComment, function (e) {
	e.addEventListener('click', addComment, false)
});

function addComment() {
	this.nextElementSibling.classList.toggle('_active');
}

// add comment end

// check comment end

// validation form start


let formSubmitBtn = document.querySelectorAll('.js_submit_form');

let inputEmail = document.querySelectorAll('input[type=email]');
let inputPassword = document.querySelectorAll('input[type=password]');
let inputText = document.querySelectorAll('input[type=text][class]');
let textareaField = document.querySelectorAll('textarea');

[].forEach.call(formSubmitBtn, function (e) {
	e.addEventListener('click', validationForm, false)
});

[].forEach.call(inputEmail, function (e) {
	e.addEventListener('keyup', validationForm, false)
});

[].forEach.call(inputPassword, function (e) {
	e.addEventListener('keyup', validationForm, false)
});

[].forEach.call(inputText, function (e) {
	e.addEventListener('keyup', validationForm, false)
});
[].forEach.call(textareaField, function (e) {
	e.addEventListener('keyup', validationForm, false)
});

function validationForm() {
	let form = this.closest('form');
	let name = form.querySelector('.js_validation_name');
	let email = form.querySelector('.js_validation_email');
	let password = form.querySelector('.js_validation_password');
	let textarea = form.querySelector('.js_validation_textarea');
	let wrongInfo = form.querySelector('.popup__wrong-field');


	if (name !== null) {

		let nameValue = name.value;

		if (nameValue !== '' && nameValue.length >= 5) {
			name.parentElement.classList.remove('invalid')
		} else {
			name.parentElement.classList.add('invalid')
		}
	}

	// if (email !== null && !this.closest('.popup-login')) {
	if (email !== null) {

		function validateEmail(emailValue) {
			const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
			return re.test(emailValue);
		}

		function validate() {
			const emailValue = email.value;

			if (validateEmail(emailValue)) {
				email.parentElement.classList.remove('invalid')
			} else {
				email.parentElement.classList.add('invalid')
			}
			return false;
		}

		validate();
	}
	// console.log(this.closest('.popup-login'))
	// if (password !== null && !this.closest('.popup-login')) {
	if (password !== null) {
		let passwordValue = password.value;

		function validateEmail(passwordValue) {
			const re = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}$/;
			return re.test(passwordValue);
		}

		function validate() {
			const passwordValue = password.value;

			if (validateEmail(passwordValue)) {
				password.parentElement.classList.remove('invalid')
			} else {
				password.parentElement.classList.add('invalid');
				// password.closest('.popup__input').querySelector('.popup__step-item-radio').classList.add('checked');
			}
			return false;
		}

		validate();

	}

	// onkeyup validation

	if (password !== null) {
		if (!password.parentElement.classList.contains('popup__input-login-password')) {
			let passwordValue = password.value;

			// Validate lowercase letters && Validate capital letters

			let lowerCaseLetters = /[a-z]/g;
			let upperCaseLetters = /[A-Z]/g;

			if (passwordValue.match(lowerCaseLetters) && passwordValue.match(upperCaseLetters)) {
				if (this.closest('.popup__form').querySelector('.letters-rule') !== null) {
					this.closest('.popup__form').querySelector('.letters-rule').querySelector('.popup__step-item-radio').classList.add('_checked');
				}
			} else {
				if (this.closest('.popup__form').querySelector('.letters-rule') !== null) {
					this.closest('.popup__form').querySelector('.letters-rule').querySelector('.popup__step-item-radio').classList.remove('_checked');
				}
			}


			// Validate numbers
			let numbers = /[0-9]/g;
			if (passwordValue.match(numbers)) {
				if (this.closest('.popup__form').querySelector('.number-rule') !== null) {
					this.closest('.popup__form').querySelector('.number-rule').querySelector('.popup__step-item-radio').classList.add('_checked');
				}
			} else {
				if (this.closest('.popup__form').querySelector('.number-rule') !== null) {
					this.closest('.popup__form').querySelector('.number-rule').querySelector('.popup__step-item-radio').classList.remove('_checked');
				}
			}

			// Validate length
			if (passwordValue.length >= 8) {
				if (this.closest('.popup__form').querySelector('.length-rule') !== null) {
					this.closest('.popup__form').querySelector('.length-rule').querySelector('.popup__step-item-radio').classList.add('_checked');
				}
			} else {
				if (this.closest('.popup__form').querySelector('.length-rule') !== null) {
					this.closest('.popup__form').querySelector('.length-rule').querySelector('.popup__step-item-radio').classList.remove('_checked');
				}
			}
		}
	}

	if (textarea !== null) {
		let textareaValue = textarea.value;

		if (textareaValue !== '' && textareaValue.length >= 6) {
			textarea.classList.remove('invalid')
		} else {
			textarea.classList.add('invalid')
		}
	}

	let allInputs = form.querySelectorAll('.popup__input');

	if (this.closest('.js__popup')) {
		if (this.closest('.js__popup').classList.contains('popup-login')) {
			[].forEach.call(allInputs, function (e) {
				if (e.classList.contains('invalid')) {
					wrongInfo.classList.add('_active');
				}
			})
		}
	}
}


// validation form end