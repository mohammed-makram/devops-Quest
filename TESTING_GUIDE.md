# Testing Guide - خطوات الاختبار

## Phase 1: اختبار Docker Compose محلياً

### الخطوة 1: التأكد من الموقع الصحيح
```powershell
cd "C:\Users\momak\OneDrive\Desktop\devops task"
Get-Location  # للتأكد أنك في المجلد الصحيح
```

### الخطوة 2: التأكد من تثبيت Docker
```powershell
docker --version
docker compose version
```

إذا لم يكن Docker مثبت، قم بتحميله من: https://www.docker.com/products/docker-desktop

### الخطوة 3: بناء الصور وتشغيل الخدمات
```powershell
# بناء وتشغيل جميع الخدمات
docker compose up --build

# أو للتشغيل في الخلفية:
docker compose up -d --build
```

### الخطوة 4: التحقق من حالة الخدمات
```powershell
# عرض حالة جميع الخدمات
docker compose ps

# عرض logs لخدمة معينة
docker compose logs vote
docker compose logs result
docker compose logs worker
docker compose logs redis
docker compose logs db
```

### الخطوة 5: اختبار الوصول للتطبيق
افتح المتصفح واذهب إلى:
- **Vote Service**: http://localhost:8080
- **Result Service**: http://localhost:8081

### الخطوة 6: إضافة بيانات تجريبية (اختياري)
```powershell
# في terminal جديد (اترك الأول يعمل)
docker compose --profile seed up
```

### الخطوة 7: إيقاف الخدمات
```powershell
# إيقاف الخدمات
docker compose down

# إيقاف وإزالة volumes (لإعادة التشغيل من الصفر)
docker compose down -v
```

---

## Phase 2: اختبار Kubernetes (إذا كان لديك Kubernetes cluster)

### الخيار 1: استخدام Minikube (للتطوير المحلي)

#### الخطوة 1: تثبيت Minikube
```powershell
# تحميل minikube من: https://minikube.sigs.k8s.io/docs/start/
minikube start --driver=docker
```

#### الخطوة 2: تفعيل Ingress
```powershell
minikube addons enable ingress
```

#### الخطوة 3: بناء الصور في Minikube
```powershell
# إما بناء الصور داخل minikube
eval $(minikube docker-env)
docker compose build

# أو دفع الصور إلى registry
```

#### الخطوة 4: تطبيق Kubernetes Manifests
```powershell
# باستخدام Kustomize
kubectl apply -k k8s/base/

# أو باستخدام Helm
cd helm/voting-app
helm dependency update
helm install voting-app . -f values-dev.yaml
```

#### الخطوة 5: التحقق من النشر
```powershell
# عرض جميع pods
kubectl get pods -n voting-app

# عرض services
kubectl get svc -n voting-app

# عرض logs
kubectl logs -f deployment/vote -n voting-app
kubectl logs -f deployment/result -n voting-app
```

#### الخطوة 6: الوصول للتطبيق
```powershell
# إذا كان ingress مفعل
minikube service vote-service -n voting-app
minikube service result-service -n voting-app

# أو port-forward
kubectl port-forward svc/vote-service 8080:80 -n voting-app
kubectl port-forward svc/result-service 8081:4000 -n voting-app
```

### الخيار 2: استخدام k3s (أسهل للتطوير المحلي)

#### الخطوة 1: تثبيت k3s
```powershell
# على Windows يمكنك استخدام WSL2 أو Docker Desktop Kubernetes
```

#### الخطوة 2: تطبيق Manifests
```powershell
kubectl apply -k k8s/base/
```

---

## Phase 3: اختبار CI/CD (GitHub Actions)

### الخطوة 1: رفع الكود إلى GitHub
```powershell
git init
git add .
git commit -m "Initial commit: Complete DevOps setup"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

### الخطوة 2: إعداد GitHub Secrets
اذهب إلى GitHub Repository → Settings → Secrets and variables → Actions

أضف:
- `AZURE_CREDENTIALS` (إذا كنت تستخدم Azure)
- `AKS_RESOURCE_GROUP`
- `AKS_CLUSTER_NAME`
- وغيرها حسب الحاجة

### الخطوة 3: مراقبة Workflows
اذهب إلى Actions tab في GitHub وسترى:
- Build and Test
- Security Scan
- Deploy (عند push للـ develop أو main)

---

## اختبارات سريعة

### اختبار Health Checks
```powershell
# اختبار Redis
docker compose exec redis redis-cli ping

# اختبار PostgreSQL
docker compose exec db psql -U postgres -c "SELECT 1;"
```

### اختبار الشبكة
```powershell
# اختبار من vote service إلى Redis
docker compose exec vote ping redis

# اختبار من result service إلى PostgreSQL
docker compose exec result ping db
```

### اختبار التصويت
1. افتح http://localhost:8080
2. اختر خيار (Cats أو Dogs)
3. افتح http://localhost:8081 في تبويب آخر
4. يجب أن ترى النتائج تظهر فوراً

---

## Troubleshooting

### مشكلة: Services لا تبدأ
```powershell
# تحقق من logs
docker compose logs

# تحقق من health checks
docker compose ps
```

### مشكلة: Ports مشغولة
```powershell
# تحقق من المنافذ المستخدمة
netstat -ano | findstr :8080
netstat -ano | findstr :8081

# غير المنافذ في docker-compose.yml إذا لزم الأمر
```

### مشكلة: Images لا تبنى
```powershell
# امسح cache وابني من جديد
docker compose build --no-cache
```

### مشكلة: Kubernetes pods في CrashLoopBackOff
```powershell
# تحقق من logs
kubectl describe pod <pod-name> -n voting-app
kubectl logs <pod-name> -n voting-app

# تحقق من events
kubectl get events -n voting-app --sort-by='.lastTimestamp'
```

---

## أوامر مفيدة

### Docker Compose
```powershell
docker compose ps              # عرض حالة الخدمات
docker compose logs -f         # عرض logs لجميع الخدمات
docker compose logs -f vote    # logs لخدمة معينة
docker compose restart vote    # إعادة تشغيل خدمة
docker compose stop            # إيقاف الخدمات
docker compose down            # إيقاف وحذف containers
docker compose down -v         # إيقاف وحذف containers و volumes
docker compose exec vote sh    # الدخول إلى container
```

### Kubernetes
```powershell
kubectl get all -n voting-app           # عرض جميع الموارد
kubectl describe pod <pod-name> -n voting-app  # تفاصيل pod
kubectl logs -f <pod-name> -n voting-app       # logs لـ pod
kubectl exec -it <pod-name> -n voting-app -- sh  # الدخول إلى pod
kubectl delete -k k8s/base/             # حذف جميع الموارد
helm list -n voting-app                  # عرض Helm releases
helm uninstall voting-app -n voting-app  # حذف Helm release
```

---

## الترتيب الموصى به للاختبار

1. ✅ **ابدأ بـ Docker Compose** (الأسهل والأسرع)
2. ✅ **جرب Minikube** (لاختبار Kubernetes محلياً)
3. ✅ **اختبر Helm charts** (لتطبيق production-ready)
4. ✅ **أرفع للـ GitHub** واختبر CI/CD

---

## ملاحظات مهمة

⚠️ **للتجربة المحلية فقط:**
- Secrets في الملفات هي للاختبار فقط
- في Production يجب استخدام Azure Key Vault أو sealed-secrets

⚠️ **Azure AKS:**
- يحتاج Azure subscription
- يحتاج Azure CLI مثبت ومفعل
- يحتاج Service Principal credentials

⚠️ **Minikube:**
- يحتاج على الأقل 2GB RAM
- يستخدم Docker Desktop أو VirtualBox

