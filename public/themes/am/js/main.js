window.onload = function () {
	let bodyElement = document.querySelector('body');
	//disable scroll body start

	//window scroll start

	let header = document.querySelector('.header'),
			moveUpBtn = document.querySelector('.move-up-btn-container');

	let windowHeight = window.innerHeight;

	window.addEventListener('scroll', function () {
		// if (window.pageYOffset > 150) {
		// 	header.classList.add('scroll');
		// } else {
		// 	header.classList.remove('scroll');
		// }

		if (window.pageYOffset > windowHeight) {
			moveUpBtn.classList.add('__active');
		} else {
			moveUpBtn.classList.remove('__active');
		}
	})

	//move to top start

	function SmoothVerticalScrolling(e, time, where) {
		var eTop = e.getBoundingClientRect().top;
		var eAmt = eTop / 100;
		var curTime = 0;
		while (curTime <= time) {
			window.setTimeout(SVS_B, curTime, eAmt, where);
			curTime += time / 100;
		}
	}

	function SVS_B(eAmt, where) {
		if (where == "center" || where == "")
			window.scrollBy(0, eAmt / 2);
		if (where == "top")
			window.scrollBy(0, eAmt);
	}

	if (moveUpBtn) {
		moveUpBtn.onclick = () => {
			let bodyElement = document.querySelector('body');

			SmoothVerticalScrolling(bodyElement, 500, "top");
		}
	}

	//move to top end

	//window scroll end

	// active page start

	let pageURL = window.location.href;
	let lastURLSegment = './' + pageURL.substr(pageURL.lastIndexOf('/') + 1);

	let links = document.querySelectorAll('.js_nav-item');

	[].forEach.call(links, function (e) {
		let linkPage = e.querySelector('a').getAttribute('href');

		if (lastURLSegment == linkPage) {
			e.classList.add('_active')
		}

		if (bodyElement.classList.contains('article-page')) {
			let urlEle = e.querySelector("a[href = './articles.html']")
			if (urlEle) {
				e.classList.add('_active');
			}
		}

		if (bodyElement.classList.contains('video-article-page')) {
			let urlEle = e.querySelector("a[href = './video.html']");
			if (urlEle) {
				e.classList.add('_active');
			}
		}

		if (bodyElement.classList.contains('photo-article-page')) {
			let urlEle = e.querySelector("a[href = './photo.html']");
			if (urlEle) {
				e.classList.add('_active');
			}
		}

	})

	// active page end

	let body = document.querySelector('body');
	let disableScrollClass = 'disable-scroll';

	//disable scroll body end

	// menu mobile start

	let btnMenuOpen = document.querySelector('.menu-open');
	let btnMenuClose = document.querySelector('.close-menu-btn');
	let mobileMenu = document.querySelector('.mobile-menu');

	if (btnMenuOpen && mobileMenu) {
		btnMenuOpen.onclick = () => {
			body.classList.add(disableScrollClass)
			mobileMenu.classList.toggle('_active');
		}
	}

	if (btnMenuClose && mobileMenu) {
		btnMenuClose.onclick = () => {
			body.classList.remove(disableScrollClass);
			mobileMenu.classList.toggle('_active');
		}
	}

	// menu mobile end


	// lang list mobile start

	let langMobileBtnOpen = document.querySelector('.js_lang_mobile_btn');
	let langMobileBtnClose = document.querySelector('.js_close-lang-btn');
	let langMobileList = document.querySelector('.js_lang_mobile_list');

	if (langMobileBtnOpen && langMobileList) {
		langMobileBtnOpen.onclick = () => {
			body.classList.add(disableScrollClass)
			langMobileList.classList.toggle('_active');
		}
	}
	if (langMobileBtnClose && langMobileList) {
		langMobileBtnClose.onclick = () => {
			body.classList.remove(disableScrollClass);
			langMobileList.classList.toggle('_active');
		}
	}

	// lang list mobile end


	// search start

	let searchPopup = document.querySelector('.js_search_list');
	let searchHeaderOpenBtn = document.querySelector('.header__search');
	let searchMobileOpenBtn = document.querySelector('.js_search_mobile_btn');
	let searchMobileCloseBtn = document.querySelector('.js_close-search-btn');

	if (searchMobileOpenBtn && searchPopup) {
		searchMobileOpenBtn.onclick = () => searchPopup.classList.toggle('_active');
	}
	if (searchHeaderOpenBtn && searchPopup) {
		searchHeaderOpenBtn.onclick = () => searchPopup.classList.toggle('_active');
	}
	if (searchMobileCloseBtn && searchPopup) {
		searchMobileCloseBtn.onclick = () => searchPopup.classList.toggle('_active');
	}


	// search end

	// filter input start

	if (bodyElement.classList.contains('articlespage') ||
			bodyElement.classList.contains('photopage') ||
			bodyElement.classList.contains('searchpage') ||
			bodyElement.classList.contains('videopage')) {


		let filterYearsOpenBtn = document.querySelector('.js_filter_years_btn')
		let filterYearsItemList = document.querySelector('.js_filter_years_list')

		if (filterYearsOpenBtn && filterYearsItemList) {
			filterYearsOpenBtn.onclick = function () {
				this.classList.toggle('_active')
				filterYearsItemList.classList.toggle('_active');
			}
		}

		let filterTagsOpenBtn = document.querySelector('.js_filter_tags_btn')
		let filterTagsItemList = document.querySelector('.js_filter_tags_list')

		if (filterTagsOpenBtn && filterTagsItemList) {
			filterTagsOpenBtn.onclick = function () {
				this.classList.toggle('_active')
				filterTagsItemList.classList.toggle('_active');
			}
		}
	}

	if (bodyElement.classList.contains('searchpage')) {

		let filterTypesOpenBtn = document.querySelector('.js_filter_types_btn')
		let filterTypesItemList = document.querySelector('.js_filter_types_list')

		if (filterTypesOpenBtn && filterTypesItemList) {
			filterTypesOpenBtn.onclick = function () {
				this.classList.toggle('_active')
				filterTypesItemList.classList.toggle('_active');
			}
		}
	}

	// filter input end


	// mobile filter start

	if (bodyElement.classList.contains('articlespage') ||
			bodyElement.classList.contains('videopage') ||
			bodyElement.classList.contains('searchpage') ||
			bodyElement.classList.contains('photopage')) {

		let filterBtnOpen = document.querySelector('.filter-icon');
		let filterBtnSection = document.querySelector('.section__filter-btn--mobile');
		let closeFilterMobile = document.querySelector('.section__filter-close--mobile');
		let filterMobile = document.querySelector('.section__filter-wrapper--mobile');

		if (filterBtnOpen && filterMobile) {
			filterBtnOpen.onclick = () => {
				filterMobile.classList.add('_active');
				body.classList.add(disableScrollClass);
			}
		}

		if (closeFilterMobile && filterMobile) {
			closeFilterMobile.onclick = () => {
				filterMobile.classList.remove('_active');
				body.classList.remove(disableScrollClass);
			}
		}

		let filterTagsOpenBtnMobile = document.querySelector('.js_filter_tags_btn_mobile');
		let filterTagsItemListMobile = document.querySelector('.js_filter_tags_list_mobile');
		let filterTagsPlusIco = document.querySelector('.js_filter_plus--tags');
		let filterTagsMinusIco = document.querySelector('.js_filter_minus--tags');

		if (filterTagsOpenBtnMobile) {
			filterTagsOpenBtnMobile.onclick = function () {
				if (filterBtnSection) filterBtnSection.classList.toggle('_active');
				if (filterTagsPlusIco) filterTagsPlusIco.classList.toggle('_active');
				if (filterTagsMinusIco) filterTagsMinusIco.classList.toggle('_active');
				if (filterTagsItemListMobile) filterTagsItemListMobile.classList.toggle('_active');
			}
		}

		let yearsOpenBtnMobile = document.querySelector('.js_filter_years_btn_mobile');
		let yearsItemListMobile = document.querySelector('.js_filter_years_list_mobile');
		let filterYearsPlusIco = document.querySelector('.js_filter_plus--years');
		let filterYearsMinusIco = document.querySelector('.js_filter_minus--years');

		if (yearsOpenBtnMobile) {
			yearsOpenBtnMobile.onclick = function () {
				if (filterBtnSection) filterBtnSection.classList.toggle('_active');
				if (filterYearsPlusIco) filterYearsPlusIco.classList.toggle('_active');
				if (filterYearsMinusIco) filterYearsMinusIco.classList.toggle('_active');
				if (yearsItemListMobile) yearsItemListMobile.classList.toggle('_active');
			}
		}

		let filterTypesOpenBtnMobile = document.querySelector('.js_filter_types_btn_mobile');
		let filterTypesItemListMobile = document.querySelector('.js_filter_types_list_mobile');
		let filterTypesPlusIco = document.querySelector('.js_filter_plus--types');
		let filterTypesMinusIco = document.querySelector('.js_filter_minus--types');

		if (filterTypesOpenBtnMobile) {
			filterTypesOpenBtnMobile.onclick = function () {
				if (filterBtnSection) filterBtnSection.classList.toggle('_active');
				if (filterTypesPlusIco) filterTypesPlusIco.classList.toggle('_active');
				if (filterTypesMinusIco) filterTypesMinusIco.classList.toggle('_active');
				if (filterTypesItemListMobile) filterTypesItemListMobile.classList.toggle('_active');
			}
		}
	}

	// mobile filter end


	//slider main page start
	setTimeout(function () {
		if (bodyElement.classList.contains('homepage')) {
			const swiper = new Swiper('.swiper-container', {
				spaceBetween: 70,
				pagination: {
					el: '.swiper-pagination',
					clickable: true,
				},
			});
		}
	}, 1600)

	//slider main page end


	// footer start

	let footer = document.querySelector('footer')
	let footerMenuPlusBtn = document.querySelector('.js_footer-menu-btn');
	let footerInfoPlusBtn = document.querySelector('.js_footer-info-btn');
	let footerPartnerPlusBtn = document.querySelector('.js_footer-partner-btn');

	if (footerMenuPlusBtn) {
		footerMenuPlusBtn.onclick = function () {
			this.nextElementSibling.classList.toggle('_active');
		}
	}
	if (footerInfoPlusBtn) {
		footerInfoPlusBtn.onclick = function () {
			this.nextElementSibling.classList.toggle('_active');
		}
	}
	if (footerPartnerPlusBtn) {
		footerPartnerPlusBtn.onclick = function () {
			this.nextElementSibling.classList.toggle('_active');
		}
	}

	// footer end


	// search page filter start


	if (bodyElement.classList.contains('searchpage')) {
		let filterTypes = document.querySelector('.js_filter_types_search_page');
		filterTypes.classList.add('_active');
	}

	// search page filter end


	// popup authorization start

	let popupAuthorization = document.querySelector('.popup-authorization');
	let authorizationBtnOpen = document.querySelectorAll('.js_authorization_open');

	[].forEach.call(authorizationBtnOpen, function (e) {
		e.addEventListener('click', openAuthorizPopup, false)
	});

	function openAuthorizPopup() {
		popupAuthorization.classList.add('open')
	}

	// popup authorization end
	
	// Comment reply form toggle
	document.querySelectorAll('.js_add_comment').forEach(function(btn) {
		btn.onclick = function(e) {
			e.preventDefault();
			e.stopPropagation();
			// Find the answer form that is sibling of this button
			let answerForm = this.nextElementSibling;
			if (answerForm && answerForm.classList.contains('section-article-item__comment-answer-form')) {
				answerForm.classList.toggle('_active');
			}
		};
	});

	// popup contact start

	let contactOpenBtn = document.querySelectorAll('.js__popup_contact_open');
	let contactPopup = document.querySelector('.popup-contact');

	[].forEach.call(contactOpenBtn, function (e) {
		e.addEventListener('click', openContactPopup, false)
	});

	function openContactPopup() {
		contactPopup.classList.add('open');
	}

	// popup contact end

	// popup login start

	let loginOpenBtn = document.querySelectorAll('.js__popup_login_open');
	let loginPopup = document.querySelector('.popup-login');

	[].forEach.call(loginOpenBtn, function (e) {
		e.addEventListener('click', openLoginPopup, false)
	});

	function openLoginPopup() {
		loginPopup.classList.add('open');
	}

	// popup login end

	// popup register start

	let registerOpenBtn = document.querySelectorAll('.js__popup_register_open');
	let registerPopup = document.querySelector('.popup-register');

	[].forEach.call(registerOpenBtn, function (e) {
		e.addEventListener('click', openRegisterPopup, false)
	});

	function openRegisterPopup() {
		registerPopup.classList.add('open');
	}

	// popup register end

	// popup mail start

	let emailOpenBtn = document.querySelectorAll('.js__popup_email_open');
	let emailPopup = document.querySelector('.popup-email');

	[].forEach.call(emailOpenBtn, function (e) {
		e.addEventListener('click', openEmailPopup, false)
	});

	function openEmailPopup() {
		emailPopup.classList.add('open');
	}

	// popup mail end

	//popup reset start

	let resetOpenBtn = document.querySelectorAll('.js_reset_popup');
	let resetPopup = document.querySelector('.popup-reset');

	[].forEach.call(resetOpenBtn, function (e) {
		e.addEventListener('click', openResetPopup, false)
	});

	function openResetPopup() {
		resetPopup.classList.add('open');
	}


	//popup reset end


	// popup close start

	let popupBtnClose = document.querySelectorAll('.js_popup_button_close');

	[].forEach.call(popupBtnClose, function (e) {
		e.addEventListener('click', closePopup, false)
	});

	function closePopup() {
		this.closest('.js__popup').classList.remove('open');
	}

	// popup close end

	// password show start

	let showPasswordBtn = document.querySelectorAll('.popup__input-ico--show');
	let hiddenPasswordBtn = document.querySelectorAll('.popup__input-ico--hidden');

	[].forEach.call(showPasswordBtn, function (e) {
		e.addEventListener('click', showPassword, false);
	});

	[].forEach.call(hiddenPasswordBtn, function (e) {
		e.addEventListener('click', hiddenPassword, false);
	});


	function showPassword() {
		this.closest('.popup__input').querySelector('input').setAttribute('type', 'password')
		this.previousElementSibling.classList.add('_active')
		this.classList.toggle('_active')
	}

	function hiddenPassword() {
		this.closest('.popup__input').querySelector('input').setAttribute('type', 'text')
		this.nextElementSibling.classList.add('_active')
		this.classList.toggle('_active')
	}

	// password show end


	// input focus start

	let inputs = document.querySelectorAll('input[class]');

	if (inputs.length) {
		[].forEach.call(inputs, function (e) {
			e.addEventListener('click', moveTitleUp, false)
		});

		[].forEach.call(inputs, function (e) {
			e.addEventListener('blur', moveTitleDown, false)
		});

		function moveTitleUp() {
			if (this.closest('.popup__input')) {
				this.closest('.popup__input').querySelector('.popup__input-title').classList.add('js_title_to_top');

				if (this.closest('.popup__input').querySelector('input[type="password"]') !== null
						&& this.closest('.popup__input').querySelector('input[type="password"]').classList.contains('js_validation_password')) {

					if (this.closest('.popup__body').querySelector('.popup__steps') !== null) {
						this.closest('.popup__body').querySelector('.popup__steps').classList.add('_active');
					}
				}
			}
		}

		function moveTitleDown() {
			if (this.value == '') {
				if (this.closest('.popup__input')) {
					this.closest('.popup__input').querySelector('.popup__input-title').classList.remove('js_title_to_top');
				}
			}
		}
	}

// input focus end


	// password rules show-hidden start

	let inputsPassword = document.querySelectorAll("input[type = 'password']");

	[].forEach.call(inputsPassword, function (e) {
		e.addEventListener('blur', hiddenRules, false);
	})

	function hiddenRules() {
		if (this.closest('.popup__body').querySelector('.popup__steps') !== null) {
			this.closest('.popup__body').querySelector('.popup__steps').classList.remove('_active');
		}
	}

	// password rules show-hidden end

	// lightgallery start

	const initLightGallery = (element, options) => {
		if (!element || typeof lightGallery !== 'function' || element.dataset.lightGalleryReady === 'true') return;
		lightGallery(element, options);
		element.dataset.lightGalleryReady = 'true';
	};

	initLightGallery(document.getElementById('lightgallery'), {
		selector: 'a',
		plugins: [lgZoom, lgThumbnail, lgShare],
		speed: 500,
		showZoomInOutIcons: true,
		actualSize: false,
		thumbnail: true,
	});

	initLightGallery(document.getElementById('static-thumbnails'), {
		animateThumb: false,
		zoomFromOrigin: false,
		allowMediaOverlap: true,
		toggleThumb: true,
	});

	initLightGallery(document.getElementById('gallery-hash-demo'), {
		customSlideName: true,
	});

	document.querySelectorAll('.section-article__content-text, .section-article-item__paragraph').forEach((container) => {
		if (!container.querySelector('.post-figure__lightbox')) return;
		initLightGallery(container, {
			selector: '.post-figure__lightbox',
			plugins: [lgZoom, lgShare],
			speed: 500,
			showZoomInOutIcons: true,
			actualSize: false,
		});
	});


	// lightgallery  end

	//video player start
	let videoPlayers = document.querySelectorAll('#video_player')

	if (videoPlayers.length) {
		const players = Array.from(videoPlayers).map(p => new Plyr(p));
	}
	//video player end

	// tippy start

	let btnPartner = document.querySelectorAll('.footer__partner-item');

	[].forEach.call(btnPartner, function (element) {

		let tooltip = element.querySelector('.footer__partner-info');

		setTimeout(function () {
			tooltip.style.display = 'block';

			tippy(element, {
				maxWidth: 250,
				content: tooltip,
				allowHTML: true,
				theme: 'light',
			});
		}, 1600)
	})

	// tippy end

	// filter functional start

	let filterFields = document.querySelectorAll('.section-content__filter-input input');

	filterFields.forEach(e => {
		e.addEventListener('click', function () {
			let filterList = e.closest('.section-content__filter').querySelector('.section-content__filter-list-wrapper');
			let filterIciClose = e.closest('.section-content__filter').querySelector('.section-content__filter-ico');
			if (!filterList || !filterIciClose) return;
			filterList.classList.add('_active');
			filterIciClose.classList.add('_active');
		})
	})


	// document.addEventListener('click', function (e) {
	// 	// console.log(document.querySelectorAll('.section-content__filter-list-wrapper'));
	// 	if(e.target.closest('.section-content__filter-list-wrapper') === null){
	// 		document.querySelectorAll('.section-content__filter-list-wrapper').forEach(e => {
	// 			console.log(e.item(e));
	// 			if(e.classList.contains('_active') === true){
	// 				// e.classList.remove('_active')
	// 			}
	// 		})
	// document.querySelectorAll('.section-content__filter-list-wrapper._active').classList.remove('_active')
	// }
	// if(e.target.closest('.section-content__filter') === null){
	// 	let filterList = e.target.querySelector('.section-content__filter-list-wrapper');
	// 	let filterIciClose = e.target.querySelector('.section-content__filter-ico');
	//
	// 	if(filterList.classList.contains('_active') && filterIciClose.classList.contains('_active') ) {
	//
	// 		filterList.classList.remove('_active')
	// 		filterIciClose.classList.remove('_active')
	// 	}
	//
	// } else {
	// 	return false
	// }
	// })


	let filterOptions = document.querySelectorAll('.js_filter_option');

	filterOptions.forEach(e => {
		e.addEventListener('change', function () {
			if (e.querySelector('input').checked) {
				let choseContainer = e.closest('.section-content__filter').querySelector('.section-content__filters-choose');
				let chosenFilter = e.closest('.section-content__filter').querySelectorAll('.js_option_chosen');
				let chosenCounter = e.closest('.section-content__filter').querySelector('.section-content__filter-counter');

				let newOption = document.createElement('div');
				let optionContent = e.querySelector('span').textContent;
				newOption.classList.add('js_option_chosen');
				newOption.setAttribute('data-option', optionContent);
				newOption.innerText = optionContent;
				choseContainer.appendChild(newOption);
				addEventOnFilterItem(newOption)
				if (chosenCounter) {
					chosenCounter.textContent = "(" + (chosenFilter.length + 1) + ")";
				}
			}

			if (!e.querySelector('input').checked) {
				let chosenFilter = e.closest('.section-content__filter').querySelectorAll('.js_option_chosen');
				let counterOption = e.closest('.section-content__filter').querySelector('.section-content__filter-counter');
				chosenFilter.forEach(item => {

					let itemAttr = item.getAttribute('data-option');
					let elemAttr = e.getAttribute('data-option');

					if (itemAttr === elemAttr) {
						item.remove();
					}
					counterOption.textContent = "(" + (chosenFilter.length - 1) + ")";
				})
			}

		});
	})

	function addEventOnFilterItem(elem) {
		elem.addEventListener('click', function () {
			let dataOption = elem.getAttribute('data-option')
			filterOptions.forEach((item) => {

				let itemDataOption = item.getAttribute('data-option');
				if (dataOption === itemDataOption) {
					item.querySelector('input').checked = false

					let chosenFilter = elem.closest('.section-content__filter').querySelectorAll('.js_option_chosen');
					let counterOption = elem.closest('.section-content__filter').querySelector('.section-content__filter-counter');
					counterOption.textContent = "(" + (chosenFilter.length - 1) + ")";
					elem.remove()
				}
			})
		})
	}

	let filterSubmit = document.querySelectorAll('.section-content__filter-btn-submit');

	filterSubmit.forEach(e => {
		e.addEventListener('click', function () {
			e.closest('.section-content__filter-list-wrapper').classList.remove('_active');
		})
	})

	let optionDelete = document.querySelectorAll('.section-content__filter-btn-delete');

	optionDelete.forEach(e => {
		e.addEventListener('click', function () {

			let choseContainer = e.closest('.section-content__filter').querySelector('.section-content__filters-choose');
			choseContainer.innerHTML = '';

			let currentFilterOption = e.closest('.section-content__filter').querySelectorAll('.js_filter_option');

			currentFilterOption.forEach((item) => {
				item.querySelector('input').checked = false;
			})

		})
	})

	let optionDeleteAll = document.querySelectorAll('.section-content__filter-rem-choose');

	optionDeleteAll.forEach(e => {
		e.addEventListener('click', function () {

			let choseContainer = document.querySelectorAll('.section-content__filters-choose');
			choseContainer.forEach(e => {
				e.innerHTML = '';
				optionCounter(e);
			})
			filterOptions.forEach((item) => {
				item.querySelector('input').checked = false
			})
		})
	})

	function optionCounter(element) {
		let allOption = element.closest('.section-content__filter').querySelectorAll('.js_option_chosen');
		let optionCounter = element.closest('.section-content__filter').querySelector('.section-content__filter-counter');
		let optionLength = allOption.length
		if (optionCounter) {
			optionCounter.textContent = "(" + (optionLength) + ")";
		}
	}

	// filter functional end

}