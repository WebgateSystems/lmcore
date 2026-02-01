<template>
	<div id="sc-page-wrapper">
		<div id="sc-page-content">
			<div class="sc-theme-dark-info uk-margin-bottom">
				Dark mode for the CKEditor rich text editor - <a href="https://ckeditor.com/cke4/addon/moono-dark">https://ckeditor.com/cke4/addon/moono-dark</a>
			</div>
			<client-only>
				<ckeditor v-model="editorData" :editor="editor" :config="editorConfig"></ckeditor>
			</client-only>
			<ScCard class="uk-margin-top">
				<ScCardBody>
					<!-- eslint-disable-next-line vue/no-v-html -->
					<div v-html="editorData"></div>
				</ScCardBody>
			</ScCard>
			<pre class="uk-margin-top"><code>{{ editorData }}</code></pre>
		</div>
	</div>
</template>

<script>
if(process.client) {
	require('@ckeditor/ckeditor5-build-classic/build/translations/ar')
	require('~/plugins/ckeditor');
}
export default {
	name: 'FormsWysiwygCkeditor',
	data: () => ({
		editorData: '<h1>لغة</h1>\n' +
			'<p>اللغة نسق من الإشارات والرموز، يشكل أداة من أدوات المعرفة، وتعتبر اللغة أهم وسائل التفاهم والاحتكاك بين أفراد المجتمع في جميع ميادين الحياة. وبدون اللغة يتعذر نشاط الناس المعرفي. وترتبط اللغة بالتفكير ارتباطًا وثيقًا؛ فأفكار الإنسان تصاغ دومًا في قالب لغوي، حتى في حال تفكيره الباطني. ومن خلال اللغة فقط تحصل الفكرة على وجودها الواقعي. كما ترمز اللغة إلى الأشياء المنعكسة فيها.</p>',
		editorConfig: {
			language: 'ar'
		}
	}),
	computed: {
		editor () {
			return process.client ? require('@ckeditor/ckeditor5-build-classic') : null
		}
	}
}
</script>
