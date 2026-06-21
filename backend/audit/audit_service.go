package audit

import (
	"log"
	"furniflow-backend/models"
	dbPkg "furniflow-backend/db"
	zapLogger "furniflow-backend/logger"
)

var auditChan = make(chan models.AuditLog, 1000)

func init() {
	go processAuditLogs()
}

func processAuditLogs() {
	db, err := dbPkg.InitDB()
	if err != nil {
		log.Println("Failed to init DB for audit worker")
		return
	}
	
	for auditEvent := range auditChan {
		if err := db.Create(&auditEvent).Error; err != nil {
			if zapLogger.Log != nil {
				zapLogger.Log.Error("Failed to save audit log async: " + err.Error())
			} else {
				log.Println("Failed to save audit log async: ", err)
			}
		}
	}
}

// LogAsync sends an audit log to the background worker
func LogAsync(auditEvent models.AuditLog) {
	select {
	case auditChan <- auditEvent:
		// successfully queued
	default:
		// channel full, drop or log synchronously
		if zapLogger.Log != nil {
			zapLogger.Log.Warn("Audit channel is full, dropping audit log")
		} else {
			log.Println("Audit channel is full, dropping audit log")
		}
	}
}
