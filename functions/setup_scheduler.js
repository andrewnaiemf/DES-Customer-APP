#!/usr/bin/env node

/**
 * 🚀 Setup Script: Create Cloud Scheduler Jobs for Ramadan 2026
 *
 * هذا السكريبت ينشئ 30 Cloud Scheduler Job
 * كل job يُطلق في الوقت المحدد قبل ساعة من المغرب
 *
 * المتطلبات:
 * - Google Cloud SDK installed (gcloud)
 * - Authenticated with gcloud
 * - Cloud Scheduler API enabled
 *
 * الاستخدام:
 * node setup_scheduler.js
 */

const { ramadanSchedule2026 } = require('./ramadan_schedule_2026');
const { exec } = require('child_process');
const util = require('util');

const execPromise = util.promisify(exec);

// ═══════════════════════════════════════════════════════════════════════════
// 📋 Configuration
// ═══════════════════════════════════════════════════════════════════════════

const CONFIG = {
  projectId: 'driveshield-d5a37',
  region: 'europe-west1',
  functionName: 'sendDailyRamadanNotification',
  timeZone: 'Asia/Riyadh',
};

const functionUrl = `https://${CONFIG.region}-${CONFIG.projectId}.cloudfunctions.net/${CONFIG.functionName}`;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Colors for console output
// ═══════════════════════════════════════════════════════════════════════════

const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// ═══════════════════════════════════════════════════════════════════════════
// 🚀 Main Function: Setup All Scheduler Jobs
// ═══════════════════════════════════════════════════════════════════════════

async function setupRamadanScheduler() {
  log('\n════════════════════════════════════════════════════════════', 'cyan');
  log('🌙 إعداد Cloud Scheduler Jobs لرمضان 2026', 'bright');
  log('════════════════════════════════════════════════════════════', 'cyan');

  log(`\n📋 المعلومات:`, 'yellow');
  log(`   - المشروع: ${CONFIG.projectId}`);
  log(`   - المنطقة: ${CONFIG.region}`);
  log(`   - Function URL: ${functionUrl}`);
  log(`   - عدد الأيام: ${ramadanSchedule2026.length}`);
  log(`   - التوقيت: ${CONFIG.timeZone}\n`);

  let successCount = 0;
  let failCount = 0;

  for (const day of ramadanSchedule2026) {
    const jobName = `ramadan-2026-day-${String(day.day).padStart(2, '0')}`;
    const [hour, minute] = day.notification.split(':');

    // تحويل التاريخ إلى صيغة CRON
    const [, month, dayOfMonth] = day.date.split('-');
    // CRON format: minute hour day month day_of_week
    const cronSchedule = `${minute} ${hour} ${dayOfMonth} ${month} *`;

    const command = `gcloud scheduler jobs create http ${jobName} \
--schedule="${cronSchedule}" \
--time-zone="${CONFIG.timeZone}" \
--uri="${functionUrl}" \
--http-method=POST \
--description="Ramadan Day ${day.day} - Iftar reminder at ${day.notification} (Maghrib: ${day.maghrib})" \
--location=${CONFIG.region} \
--attempt-deadline=320s`;

    try {
      log(`📅 [${day.day}/30] إنشاء Job لليوم ${day.day} (${day.date} ${day.notification})...`, 'cyan');
      log(`   ⏰ CRON: ${cronSchedule}`, 'yellow');

      await execPromise(command);

      log(`   ✅ تم إنشاء: ${jobName}\n`, 'green');
      successCount++;
    } catch (error) {
      log(`   ❌ خطأ في إنشاء ${jobName}:`, 'red');
      log(`   ${error.message}\n`, 'red');
      failCount++;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Summary
  // ═══════════════════════════════════════════════════════════════════════

  log('\n════════════════════════════════════════════════════════════', 'cyan');
  log('📊 ملخص العملية', 'bright');
  log('════════════════════════════════════════════════════════════', 'cyan');
  log(`✅ نجح: ${successCount}`, 'green');
  log(`❌ فشل: ${failCount}`, failCount > 0 ? 'red' : 'green');
  log(`📊 الإجمالي: ${successCount + failCount}`);

  if (successCount > 0) {
    log('\n🎉 تم إنشاء Cloud Scheduler Jobs بنجاح!', 'green');
    log('🔍 للتحقق من Jobs:', 'yellow');
    log(`   https://console.cloud.google.com/cloudscheduler?project=${CONFIG.projectId}\n`, 'cyan');
  }

  if (failCount > 0) {
    log('\n⚠️ بعض Jobs فشلت. تحقق من الأخطاء أعلاه.', 'yellow');
  }

  log('════════════════════════════════════════════════════════════\n', 'cyan');
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧹 Function: Delete All Ramadan Jobs (للتنظيف)
// ═══════════════════════════════════════════════════════════════════════════

async function deleteAllRamadanJobs() {
  log('\n🧹 حذف جميع Ramadan Scheduler Jobs...', 'yellow');

  for (const day of ramadanSchedule2026) {
    const jobName = `ramadan-2026-day-${String(day.day).padStart(2, '0')}`;
    const command = `gcloud scheduler jobs delete ${jobName} --location=${CONFIG.region} --quiet`;

    try {
      await execPromise(command);
      log(`✅ تم حذف: ${jobName}`, 'green');
    } catch (error) {
      log(`⚠️ لم يتم العثور على: ${jobName}`, 'yellow');
    }
  }

  log('✅ تم حذف جميع Jobs بنجاح!\n', 'green');
}

// ═══════════════════════════════════════════════════════════════════════════
// 🧪 Function: Test a Single Job
// ═══════════════════════════════════════════════════════════════════════════

async function testJob(dayNumber) {
  const jobName = `ramadan-2026-day-${String(dayNumber).padStart(2, '0')}`;

  log(`\n🧪 اختبار Job: ${jobName}...`, 'cyan');

  const command = `gcloud scheduler jobs run ${jobName} --location=${CONFIG.region}`;

  try {
    const { stdout } = await execPromise(command);
    log(`✅ تم تشغيل Job بنجاح!`, 'green');
    log(stdout);
  } catch (error) {
    log(`❌ خطأ في تشغيل Job:`, 'red');
    log(error.message, 'red');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 CLI Arguments Handler
// ═══════════════════════════════════════════════════════════════════════════

const command = process.argv[2];

switch (command) {
  case 'delete':
    deleteAllRamadanJobs().catch(console.error);
    break;

  case 'test': {
    const dayNumber = parseInt(process.argv[3]) || 1;
    testJob(dayNumber).catch(console.error);
    break;
  }

  case 'setup':
  default:
    setupRamadanScheduler().catch(console.error);
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Usage Instructions
// ═══════════════════════════════════════════════════════════════════════════

if (command === 'help' || command === '--help' || command === '-h') {
  log('\n📚 الاستخدام:', 'bright');
  log('  node setup_scheduler.js [command]', 'cyan');
  log('\n🎯 الأوامر:', 'bright');
  log('  setup (افتراضي) - إنشاء جميع Cloud Scheduler Jobs', 'green');
  log('  delete          - حذف جميع Ramadan Jobs', 'yellow');
  log('  test [day]      - اختبار job محدد (مثال: test 1)', 'cyan');
  log('  help            - عرض هذه المساعدة\n', 'magenta');
  process.exit(0);
}
