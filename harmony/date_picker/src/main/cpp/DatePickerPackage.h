#pragma once

// This file was generated.

#include "RNOH/Package.h"
#include "RNDatePickerComponentDescriptor.h"
#include "RNDatePickerJSIBinder.h"

namespace rnoh {

class DatePickerEventEmitRequestHandler : public EventEmitRequestHandler {
public:
    void handleEvent(Context const &ctx) override {
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<facebook::react::EventEmitter>(ctx.tag);
        if (eventEmitter == nullptr) {
            return;
        }

        std::vector<std::string> supportedEventNames = {
            "change",
            "confirm",
            "cancel"
        };
        if (std::find(supportedEventNames.begin(), supportedEventNames.end(), ctx.eventName) !=
            supportedEventNames.end()) {
            eventEmitter->dispatchEvent(ctx.eventName, ArkJS(ctx.env).getDynamic(ctx.payload));
        }
    }
};

class DatePickerPackage : public Package {
public:
    DatePickerPackage(Package::Context ctx) : Package(ctx){};

    std::vector<facebook::react::ComponentDescriptorProvider> createComponentDescriptorProviders() override {
        return {
            facebook::react::concreteComponentDescriptorProvider<facebook::react::RNDatePickerComponentDescriptor>(),
        };
    }

    ComponentJSIBinderByString createComponentJSIBinderByName() override {
        return {
            {"RNDatePicker", std::make_shared<RNDatePickerJSIBinder>()},
        };
    };

    EventEmitRequestHandlers createEventEmitRequestHandlers() override {
        return {
            std::make_shared<DatePickerEventEmitRequestHandler>(),
        };
    }
};
} // namespace rnoh