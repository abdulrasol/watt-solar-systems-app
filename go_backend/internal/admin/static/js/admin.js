function adminShell() {
	return {
		sidebar: false,
		activeSection: 'overview',
		darkMode: localStorage.getItem('adminDarkMode') === 'true',
		icons: {
			grid: '⊞', toggle: '⚙', users: '👥', globe: '🌐', map: '🗺',
			coins: '💰', badge: '🏅', layers: '📑', building: '🏢',
			clipboard: '📋', spark: '⚡', image: '🖼', bolt: '⚡',
			bell: '🔔', message: '💬', megaphone: '📢', package: '📦',
		},
		init() {
			this.activeSection = window.location.pathname.replace('/admin/config/section/', '') || 'overview';
			if (this.darkMode) document.documentElement.classList.add('dark');
		},
		icon(name) { return this.icons[name] || '•'; },
		closeSidebar() { this.sidebar = false; },
		loadSection(key) { this.activeSection = key; this.sidebar = false; },
		sectionLabel(key) {
			const map = {
				overview: 'نظرة عامة', configs: 'الإعدادات', users: 'المستخدمون',
				countries: 'الدول', cities: 'المدن', currencies: 'العملات',
				subscriptions: 'باقات الاشتراك', categories: 'التصنيفات العامة',
				companies: 'الشركات', 'company-types': 'أنواع الشركات',
				'subscription-requests': 'طلبات الاشتراك', 'service-types': 'أنواع الخدمات',
				posters: 'البوسترات', systems: 'الأنظمة', notifications: 'الإشعارات',
				feedbacks: 'الملاحظات', offers: 'العروض والطلبات', products: 'المنتجات',
			};
			return map[key] || key;
		},
		refresh() { htmx.trigger('#main-content', 'htmx:refresh'); },
		toggleDark() {
			this.darkMode = !this.darkMode;
			localStorage.setItem('adminDarkMode', this.darkMode);
			document.documentElement.classList.toggle('dark', this.darkMode);
		},
	};
}

function crudSection(section) {
	return {
		showModal: false,
		modalTitle: '',
		section: section,
		openModal(mode) {
			this.showModal = true;
			this.modalTitle = mode === 'create' ? 'إضافة جديدة' : 'تعديل';
		},
		closeModal() {
			this.showModal = false;
		},
	};
}
