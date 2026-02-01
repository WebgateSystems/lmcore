<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<textarea id="wysiwyg-ckeditor" cols="30" rows="20" hidden>
            <?php if($isRTL) { ?>
                <h1>لغة</h1>
                <p>اللغة نسق من الإشارات والرموز، يشكل أداة من أدوات المعرفة، وتعتبر اللغة أهم وسائل التفاهم والاحتكاك بين أفراد المجتمع في جميع ميادين الحياة. وبدون اللغة يتعذر نشاط الناس المعرفي. وترتبط اللغة بالتفكير ارتباطًا وثيقًا؛ فأفكار الإنسان تصاغ دومًا في قالب لغوي، حتى في حال تفكيره الباطني. ومن خلال اللغة فقط تحصل الفكرة على وجودها الواقعي. كما ترمز اللغة إلى الأشياء المنعكسة فيها.</p>
            <?php } else { ?>
            <figure class="image image-style-align-left"><img src="assets/img/photos/san-fermin-pamplona-navarra-768251-unsplash_md.jpg" alt=""></figure>
            <h1>Header</h1>
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Amet consequuntur deleniti ducimus, eos fugit, mollitia neque praesentium quia quisquam quos sapiente voluptatem voluptatibus voluptatum. Assumenda consectetur deleniti doloremque fuga harum illum molestiae nisi possimus quidem vero. A accusantium alias aliquam animi cum doloremque eos est facilis illo, illum inventore ipsam itaque laboriosam maiores modi mollitia necessitatibus nemo non omnis perferendis quam quia, repellendus rerum vel veritatis voluptas voluptate?</p><p>&nbsp;</p>
            <figure class="table"><table><thead><tr><th>Name</th><th>Email</th><th>Phone Number</th></tr></thead><tbody><tr><td>John Smith</td><td>jsmith@example.com</td><td>555-234-234</td></tr></tbody></table></figure>
            <?php } ?>
		</textarea>
		<div class="uk-margin-top">
			<button class="sc-button sc-button-primary" type="button" data-uk-toggle="target: #wysiwyg-ckeditor-modal">Show Data</button>
			<div id="wysiwyg-ckeditor-modal" data-uk-modal>
				<div class="uk-modal-dialog uk-modal-body">
					<button class="uk-modal-close-default" type="button" data-uk-close></button>
					<h2 class="uk-modal-title">CKEditor Data</h2>
<pre class="uk-overflow-hidden uk-width-1-1 uk-text-wrap"><code id="wysiwyg-ckeditor-data"></code></pre>
				</div>
			</div>
		</div>
        <div class="sc-theme-dark-info uk-margin-top">
            Dark mode for the CKEditor rich text editor - <a href="https://ckeditor.com/cke4/addon/moono-dark">https://ckeditor.com/cke4/addon/moono-dark</a>
        </div>
	</div>
</div>
